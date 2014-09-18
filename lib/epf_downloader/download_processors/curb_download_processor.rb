require 'curb'
require 'ruby-progressbar'

module EpfDownloader
  module DownloadProcessors
    class CurbDownloadProcessor < EpfDownloader::DownloadProcessor
      def init_download
        fetch_md5 do |on|
          on.success do
            fetch_main
          end
        end
      end

      private

      def fetch_md5(&block)
        callbacks = Helpers::Callbacks.new(block)

        download_file(md5_url) do |on, curl|
          on.success do
            @md5_checksum = curl.body_str.match(/.*=(.*)/)[1].strip

            callbacks.call(:success)
          end
        end
      end

      def fetch_main
        download_file(download_url) do |on, curl|
          on.success do
            raise StandardError.new 'md5 mismatch!' unless file_valid?
          end

          on.progress do |now, total, progress|
            if progress == 1
              @progressbar.finish
            else
              @progressbar.progress = progress
            end
          end

          on.body do |data|
            File.open(filepath, 'a:ASCII-8BIT') do |f|
              f << data.force_encoding("ASCII-8BIT")
              data.size
            end
          end
        end
      end

      def download_file(url, &block)
        with_curl(url) do |curl|
          callbacks = Helpers::Callbacks.new(block, curl)

          curl.on_complete { callbacks.call :complete }
          curl.on_success { callbacks.call :success }
          curl.on_failure { |status| callbacks.call :failure, status }

          if callbacks.responds_to? :body
            curl.on_body { |data| callbacks.call :body, data}
          end

          curl.on_progress do |total, now|
            ratio = now / total.to_f
            ratio = 0 if total == 0

            callbacks.call(:progress, total, now, ratio)

            true #always return true
          end

          curl.perform
        end
      end

      def with_curl(url)
        curl = Curl::Easy.new(url)
        curl.http_auth_types = :basic

        curl.username = epf_id
        curl.password = epf_password

        yield curl
      end
    end
  end
end
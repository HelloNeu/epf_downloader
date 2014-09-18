require 'net/http'
require 'uri'
require 'ruby-progressbar'

module EpfDownloader
  module DownloadProcessors
    class NetHttpDownloadProcessor < EpfDownloader::DownloadProcessor
      def init_download
        @download_retry = 0

        fetch_md5
        fetch_main

        raise StandardError.new 'md5 mismatch!' unless file_valid?
      end

      private

      def fetch_md5
        EpfDownloader.logger.info("Fetching MD5")

        uri = URI.parse(@md5_url)

        connect(uri) do |http|
          @md5_checksum = http.request(request(uri)).body.match(/.*=(.*)/)[1].strip
        end
      end

      def fetch_main
        uri = URI.parse(@download_url)

        headers = {
          'Accept-Encoding' => 'identity'
        }

        if exist?
          file_size = File.size(@file_path).to_i
          headers['Range']  = "bytes=#{file_size}-"
        end

        download_progress = 0.0

        ::EpfDownloader.logger.info("Starting at : #{download_progress} bytes")

        begin
          connect(uri) do |http|
            http.request(request(uri, headers)) do |response|
              File.open(@file_path, 'a:ASCII-8BIT') do |io|
                response.read_body do |chunk|
                  io.write chunk.force_encoding('ASCII-8BIT')

                  download_total      = response['Content-Length'].to_i
                  download_progress  += chunk.length

                  ratio               = download_progress / download_total rescue 0
                  ratio               = [0, [1, ratio].min].max

                  if ratio < 1
                    @progressbar.progress = ratio
                  end
                end
              end
            end
          end
        rescue Exception => e
          @download_retry += 1

          if @download_retry < EpfDownloader.config.download_retry_count
            ::EpfDownloader.logger.info("Download failed, retry: #{@download_retry} of #{EpfDownloader.config.download_retry_count}, exception: #{e}")

            fetch_main
          else
            raise e
          end
        end
      end

      def connect(uri, &block)
        Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https'), &block)
      end

      def request(uri, headers = {})
        _request = Net::HTTP::Get.new(uri.request_uri, headers)
        _request.basic_auth(@epf_id, @epf_password)
        _request
      end
    end
  end
end
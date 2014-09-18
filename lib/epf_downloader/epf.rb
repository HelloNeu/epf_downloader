require 'active_support/core_ext'
require 'pathname'

module EpfDownloader
  module Epf
    module BaseActions
      ITUNES_FEED_URL = 'https://feeds.itunes.apple.com/feeds/epf/v3/full'.freeze
      EPF_UPDATE_WEEK_DAY = :wednesday

      attr_reader :epf_id, :epf_password, :extract_dir, :content_type

      def initialize(options = {})
        @epf_id = options.fetch(:epf_id, EpfDownloader.config.epf_id)
        @epf_password = options.fetch(:epf_password, EpfDownloader.config.epf_password)
        @extract_dir = options.fetch(:extract_dir, EpfDownloader.config.extract_dir)
        @content_type = options.fetch(:content_type, EpfDownloader.config.content_type)

        raise StandardError.new('Apple credentials not found') if epf_id.nil? || epf_password.nil?
        raise StandardError.new('Extract dir not found') if extract_dir.nil?
      end

      def url
        File.join(ITUNES_FEED_URL, path)
      end

      def file_name(date)
        "#{content_type}#{date.strftime('%Y%m%d')}.tbz"
      end

      def md5_url
        "#{url}.md5"
      end

      def incremental_date
        Date.today.prev_day(2)
      end

      def full_update_date
        incremental_date.beginning_of_week(EPF_UPDATE_WEEK_DAY)
      end

      def download_dir
        Pathname(extract_dir).join(type)
      end

      private

      def downloader
        EpfDownloader.config.download_processor.new(epf_id, epf_password, url, md5_url, download_dir)
      end
    end

    class Incremental
      include BaseActions

      def type
        'incremental'
      end

      def path
        File.join(full_update_date.strftime('%Y%m%d'), 'incremental', incremental_date.strftime('%Y%m%d'), file_name(incremental_date))
      end

      def download
        raise StandardError.new('Today no updates were posted') if [5, 6].include?(incremental_date.wday)

        downloader.download
      end
    end

    class Full
      include BaseActions

      def type
        'full'
      end

      def path
        File.join(full_update_date.strftime('%Y%m%d'), file_name(full_update_date))
      end

      def download
        downloader.download
      end
    end
  end
end

require 'epf_downloader/logger'
require 'epf_downloader/helpers'
require 'epf_downloader/errors'
require 'epf_downloader/epf'
require 'epf_downloader/download_processor'
require 'epf_downloader/download_processors/curb_download_processor'
require 'epf_downloader/download_processors/net_http_download_processor'

module EpfDownloader
  class Configuration
    attr_accessor :epf_id, :epf_password, :extract_dir, :content_type, :download_retry_count, :download_processor, :overwrite

    def initialize
      @epf_id = nil
      @epf_password = nil
      @extract_dir = nil
      @content_type = :itunes
      @download_retry_count = 3
      @download_processor = EpfDownloader::DownloadProcessors::NetHttpDownloadProcessor
      @overwrite = false
    end
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield(config) if block_given?
  end

  def self.logger
    EpfDownloader::Logging.logger
  end

  def self.logger=(log)
    EpfDownloader::Logging.logger = log
  end
end
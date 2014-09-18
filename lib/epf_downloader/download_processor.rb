require 'digest/md5'
require 'pathname'
require 'fileutils'

module EpfDownloader
  class DownloadProcessor
    def initialize(epf_id, epf_password, download_url, md5_url, download_dir)
      @epf_id = epf_id
      @epf_password = epf_password
      @download_url = download_url
      @md5_url = md5_url

      unless File.directory?(download_dir)
        FileUtils.mkdir_p(download_dir)
      end

      @file_path = Pathname(download_dir).join(File.basename(download_url))
      @progressbar = ProgressBar.create(total: 1, format: '%a %B %p%% %t')
    end

    def download
      if EpfDownloader.config.overwrite && exist?
        logger.info("Removing existing file: #{@file_path}")

        File.delete(file_path)
      end

      EpfDownloader.logger.info("Downloading: #{@download_url}")
      EpfDownloader.logger.info("To: #{@file_path}")

      init_download

      @file_path
    end

    def init_download
      raise StandardError.new 'Subclass this.'
    end

    protected

    def exist?
      File.exist?(@file_path)
    end

    def file_valid?
      raise StandardError.new 'File doesn\'t exist' unless File.exist?(@file_path)
      raise StandardError.new 'MD5 not fetched yet' if @md5_checksum.nil?

      md5_file_calculated = Digest::MD5.file(@file_path).hexdigest
      md5_file_calculated == @md5_checksum
    end
  end
end
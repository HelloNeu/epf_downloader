  module EpfDownloader
    class DownloaderError < StandardError; end
    class FileNotExist < DownloaderError; end
    class CurlError < DownloaderError; end
    class HttpHeaderError < DownloaderError; end
    class Md5CompareError < DownloaderError; end
    class BadCredentialsError < StandardError; end
  end

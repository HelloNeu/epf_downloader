require 'helper'

class EpfTest < ActiveSupport::TestCase
  setup do
    stub_request(:get, "https://123:123@feeds.itunes.apple.com/feeds/epf/v3/full/20140129/itunes20140129.tbz.md5").
      to_return(:status => 200, :body => 'MD5 (itunes20140812.tbz) = 026de5fd5025e642a920a2fd6a9944a7', :headers => {})

    stub_request(:get, "https://123:123@feeds.itunes.apple.com/feeds/epf/v3/full/20140129/itunes20140129.tbz").
      to_return(:status => 200, :body => 'data response', :headers => {})

    stub_request(:get, "https://123:123@feeds.itunes.apple.com/feeds/epf/v3/full/20140129/incremental/20140203/itunes20140203.tbz.md5").
      to_return(:status => 200, :body => 'MD5 (itunes20140203.tbz) = 026de5fd5025e642a920a2fd6a9944a7', :headers => {})

    stub_request(:get, "https://123:123@feeds.itunes.apple.com/feeds/epf/v3/full/20140129/incremental/20140203/itunes20140203.tbz").
      to_return(:status => 200, :body => 'data response', :headers => {})

    EpfDownloader::DownloadProcessor.any_instance.stubs(:file_valid?).returns(true)

    @tmp_dir = [Dir.tmpdir, 'epf'].join('/')
  end

  test 'full download' do
    FileUtils.mkpath @tmp_dir

    new_time = Time.local(2014, 2, 2, 12, 0, 0)
    Timecop.freeze(new_time)

    downloader = EpfDownloader::Epf::Full.new(epf_id: '123', epf_password: '123', extract_dir: @tmp_dir)
    path = downloader.download

    assert_equal IO.read(path), 'data response'

    FileUtils.remove_dir @tmp_dir
  end

  test 'incremental download' do
    FileUtils.mkpath @tmp_dir

    new_time = Time.local(2014, 2, 5, 12, 0, 0)
    Timecop.freeze(new_time)

    downloader = EpfDownloader::Epf::Incremental.new(epf_id: '123', epf_password: '123', extract_dir: @tmp_dir)
    path = downloader.download

    assert_equal IO.read(path), 'data response'

    FileUtils.remove_dir @tmp_dir
  end

  test 'incremental download should raise error' do
    new_time = Time.local(2014, 2, 2, 12, 0, 0)
    Timecop.freeze(new_time)

    downloader = EpfDownloader::Epf::Incremental.new(epf_id: '123', epf_password: '123', extract_dir: @tmp_dir)

    assert_raise StandardError do
      downloader.download
    end
  end
end
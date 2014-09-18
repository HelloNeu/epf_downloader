```
$LOAD_PATH.unshift "/Users/edo/Sites/epf_downloader/lib"
require 'epf_downloader'

EpfDownloader.configure do |config|
  config.content_type = :match
end

downloader = EpfDownloader::Epf::Incremental.new(
  epf_id: 'epf_id',
  epf_password: 'epf_pw',
  extract_dir: './epf'
)
downloader.download
```
CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => configatron.aws.access_key,
    :aws_secret_access_key  => configatron.aws.secret_key
  }
  config.fog_directory = configatron.aws.s3_bucket
  config.fog_host = configatron.aws.s3_host
  config.storage :fog
end

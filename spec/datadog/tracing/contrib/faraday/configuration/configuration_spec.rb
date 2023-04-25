require 'datadog/tracing/contrib/faraday/configuration/settings'
require 'datadog/tracing/contrib/service_name_settings_examples'

RSpec.describe Datadog::Tracing::Contrib::Faraday::Configuration::Settings do
  it_behaves_like 'service name setting', 'faraday'
end

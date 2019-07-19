require 'spec_helper'
require 'roda'
require 'ddtrace'
require 'ddtrace/contrib/roda/instrumentation'
require 'ddtrace/contrib/roda/ext'
require 'ddtrace/contrib/roda/shared_examples'

RSpec.describe Datadog::Contrib::Roda::Instrumentation do
  describe 'when implemented in Roda' do
    let(:configuration_options) { { tracer: tracer } }
    let(:tracer) { get_test_tracer }
    let(:spans) { tracer.writer.spans }
    let(:span) { spans.first }
    let(:roda) { test_class.new }
    let(:test_class) do
      Class.new do
        prepend Datadog::Contrib::Roda::Instrumentation
      end
    end
    before(:each) do
      Datadog.configure do |c|
        c.use :roda, configuration_options
      end
    end

    after(:each) do
      Datadog.registry[:roda].reset_configuration!
    end

    describe '#datadog_pin' do
      let(:env) { { REQUEST_METHOD: 'GET' } }
      subject(:datadog_pin) { roda.datadog_pin }

      context 'when roda is configured' do
        context 'with default settings' do
          it 'enables the tracer' do
            expect(datadog_pin.tracer).to be(Datadog.configuration[:roda][:tracer])
            expect(datadog_pin.tracer.enabled).to eq(true)
          end

          it 'has a web app type' do
            expect(datadog_pin.app_type).to eq(Datadog::Ext::AppTypes::WEB)
          end

          it 'has a default name' do
            expect(datadog_pin.app).to eq(Datadog::Contrib::Roda::Ext::APP)
            expect(datadog_pin.service).to eq(Datadog::Contrib::Roda::Ext::SERVICE_NAME)
            expect(datadog_pin.service_name).to eq(Datadog::Contrib::Roda::Ext::SERVICE_NAME)
          end

          context 'with a custom service name' do
            let(:custom_service_name) { 'custom service name' }
            let(:configuration_options) { { tracer: tracer, service_name: custom_service_name } }

            it 'sets a custom service name' do
              expect(datadog_pin.app).to eq(Datadog::Contrib::Roda::Ext::APP)
              expect(datadog_pin.service).to eq(custom_service_name)
              expect(datadog_pin.service_name).to eq(custom_service_name)
            end
          end
        end
      end
    end

    describe 'when application calls on the instrumented method' do
      context '#call' do
        it_behaves_like 'shared examples for roda', :call
      end
      context '#_roda_handle_main_route' do
        it_behaves_like 'shared examples for roda', :_roda_handle_main_route
      end
    end
  end
end

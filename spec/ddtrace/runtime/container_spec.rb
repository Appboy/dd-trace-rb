# encoding: utf-8

require 'spec_helper'
require 'ddtrace/runtime/container'

RSpec.describe Datadog::Runtime::Container do
  describe '::parse_line' do
    subject(:parse_line) { described_class.parse_line(line) }

    context 'given a line' do
      context 'in Docker format' do
        let(:line) { '13:name=systemd:/docker/3726184226f5d3147c25fdeab5b60097e378e8a720503a5e19ecfdf29f869860' }
        it { is_expected.to be_a_kind_of(described_class::Descriptor) }
        it do
          is_expected.to have_attributes(
            id: '13',
            groups: 'name=systemd',
            path: '/docker/3726184226f5d3147c25fdeab5b60097e378e8a720503a5e19ecfdf29f869860',
            controllers: ['name=systemd']
          )
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'datadog/core/remote/worker'

RSpec.describe Datadog::Core::Remote::Worker do
  let(:task) { proc { 1 + 1 } }
  subject(:worker) { described_class.new(interval: 1, &task) }

  describe '#initialize' do
    it 'raises ArgumentError when no block is provided' do
      expect do
        described_class.new(interval: 1)
      end.to raise_error(ArgumentError)
    end
  end

  describe '#start' do
    after { worker.stop }

    it 'mark worker as started' do
      expect(worker).not_to be_started
      worker.start
      expect(worker).to be_started
    end

    it 'acquire and release lock' do
      expect(worker).to receive(:acquire_lock).at_least(:once)
      expect(worker).to receive(:release_lock).at_least(:once)
      worker.start
    end

    context 'execute block when started' do
      let(:result) { [] }
      let(:queue) { Queue.new }
      let(:task) do
        proc do
          value = 1
          result << value
          queue << value
        end
      end

      it 'runs block' do
        worker.start
        # Wait for the work task to execute once
        queue.pop
        expect(result).to eq([1])
      end
    end
  end

  describe '#stop' do
    it 'mark worker as stopped' do
      expect(worker).not_to be_started
      worker.start
      expect(worker).to be_started
      worker.stop
      expect(worker).not_to be_started
    end

    it 'acquire and release lock' do
      expect(worker).to receive(:acquire_lock)
      expect(worker).to receive(:release_lock)
      worker.stop
    end
  end
end

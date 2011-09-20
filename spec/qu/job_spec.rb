require 'spec_helper'

describe Qu::Job do
  class MyJob
    @queue = :custom
  end

  describe 'queue' do
    it 'should default to "default"' do
      Qu::Job.new('1', SimpleJob, []).queue.should == 'default'
    end

    it 'should get queue from job instance variable' do
      Qu::Job.new('1', MyJob, []).queue.should == 'custom'
    end
  end

  describe 'klass' do
    it 'should constantize string' do
      Qu::Job.new('1', 'MyJob', []).klass.should == MyJob
    end

    it 'should find namespaced jobs' do
      Qu::Job.new('1', 'Qu::Job', []).klass.should == Qu::Job
    end
  end

  describe 'perform' do
    subject { Qu::Job.new('1', SimpleJob, ['a', 'b']) }

    it 'should call .perform on job class with args' do
      SimpleJob.should_receive(:perform).with('a', 'b')
      subject.perform
    end

    context 'when the job raises an error' do
      let(:error) { Exception.new("Some kind of error") }

      before do
        SimpleJob.stub!(:perform).and_raise(error)
      end

      it 'should call failed on backend' do
        Qu.backend.should_receive(:failed).with(subject, error)
        subject.perform
      end
    end

  end
end

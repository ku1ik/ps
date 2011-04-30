require 'spec_helper'

describe Ps do
  describe '.all' do
    let(:opts) { {} }

    subject { Ps.all(opts) }

    it 'should call ProcTable.ps to get process list' do
      Sys::ProcTable.should_receive(:ps).and_return([])

      subject
    end

    it { should be_a(Array) }

    its(:first) { should be_a(Hash) }

    its(:first) { should have_key(:pid) }

    context 'when filter option given' do
      let(:opts) { { :filter => 'init' } }

      specify { subject.map { |info| info[:comm] }.uniq.should have(1).items }
    end

    context 'when order option given' do
      let(:opts) { { :order => 'rss' } }

      specify do
        mem_usages = subject.map { |info| info[:rss] }
        0.upto(mem_usages.size - 2) do |i|
          mem_usages[i].should be >= mem_usages[i+1]
        end
      end
    end
  end

  describe '.details' do
    let(:pid) { 1234 }

    subject { Ps.details(pid) }

    it 'should call ProcTable.ps(pid) to get details for single process' do
      proc_table = Struct::ProcTableStruct.new(:pid => pid)
      Sys::ProcTable.should_receive(:ps).with(pid).and_return(proc_table)

      subject
    end

    context 'when there is no process for given pid' do
      let(:pid) { Ps::MAX_PID + 1 }

      it { should be_nil }
    end

    context 'when there is a process for given pid' do
      let(:pid) { 1 } # pid of "init" process, always present

      it { should be_a(Hash) }

      it 'should return info for correct process' do
        subject[:pid].should == pid
      end
    end
  end
end

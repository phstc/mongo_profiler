require 'spec_helper'

module MongoProfiler
  describe Caller do
    subject { described_class.new(_caller) }

    let(:_caller) {
      [
        "/Users/pablo/workspace/project/test.rb:7:in `new'",
        "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `block (2 levels) in let'",
        "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `fetch'",
        "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `block in let'"
      ]
    }

    its(:file)    { should end_with('project/test.rb') }
    its(:line)    { should eq 7 }
    its(:method)  { should eq 'new' }
    its(:_caller) { should eq _caller }

    context 'when backtrace starts with bundle or gem' do
      let(:_caller) {
        [
          "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `block (2 levels) in let'",
          "/Users/pablo/bundle/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `block (2 levels) in let'",
          "/Users/pablo/workspace/project/test.rb:7:in `new'",
          "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `fetch'",
          "/Users/pablo/.gem/ruby/2.0.0/gems/rspec-core-2.14.4/lib/rspec/core/memoized_helpers.rb:199:in `block in let'"
        ]
      }

      its(:file)    { should end_with('project/test.rb') }
      its(:line)    { should eq 7 }
      its(:method)  { should eq 'new' }
      its(:_caller) { should eq _caller }
    end
  end
end

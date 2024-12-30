# tests/targets/DELPHY/test_delphy_script.rb
require_relative 'test_helper'

RSpec.describe DelphyScript do
  before(:each) do
    @script = DelphyScript.new
  end

  it 'connects successfully to DELPHY' do
    expect { @script.connect }.not_to raise_error
    @logger.info('Connection test passed')
  end

  it 'executes a workflow successfully' do
    expect { @script.execute_full_workflow(1, 123.45) }.not_to raise_error
    @logger.info('Workflow test passed')
  end

  it 'handles invalid command gracefully' do
    expect { @script.run_script(nil, nil) }.to raise_error(StandardError)
    @logger.info('Invalid command test passed')
  end

  after(:each) do
    @script.disconnect
  end
end

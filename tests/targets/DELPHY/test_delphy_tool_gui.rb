# tests/targets/DELPHY/test_delphy_tool_gui.rb
require_relative 'test_helper'

RSpec.describe DelphyToolGUI do
  before(:each) do
    @gui = DelphyToolGUI.new
  end

  it 'initializes GUI successfully' do
    expect { @gui.setup_ui }.not_to raise_error
    @logger.info('GUI initialization test passed')
  end

  it 'handles connect button correctly' do
    expect { @gui.handle_connect }.not_to raise_error
    @logger.info('GUI connect button test passed')
  end

  it 'handles reset button correctly' do
    expect { @gui.handle_reset_system }.not_to raise_error
    @logger.info('GUI reset button test passed')
  end

  after(:each) do
    @gui.handle_exit
  end
end

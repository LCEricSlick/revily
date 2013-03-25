require 'spec_helper'

describe Schedule do
  describe 'associations' do
    it { should have_many(:schedule_layers) }
    it { should have_many(:user_schedule_layers).through(:schedule_layers) }
    it { should have_many(:users).through(:user_schedule_layers) }    
    it { should have_many(:escalation_rules) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:start_at) }
    it { should validate_presence_of(:time_zone) }
  end

  describe 'attributes' do
    it { should have_readonly_attribute(:uuid) }
  end

end

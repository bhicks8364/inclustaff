# == Schema Information
#
# Table name: shifts
#
#  id             :integer          not null, primary key
#  time_in        :datetime
#  time_out       :datetime
#  employee_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  time_worked    :decimal(, )
#  job_id         :integer
#  state          :string
#  earnings       :decimal(, )
#  timesheet_id   :integer
#  deleted_at     :datetime
#  in_ip          :string
#  out_ip         :string
#  week           :integer
#  break_in       :datetime
#  break_out      :datetime
#  note           :text
#  needs_adj      :boolean
#  break_duration :decimal(, )
#  breaks         :text             is an Array
#

require 'rails_helper'

RSpec.describe Shift, type: :model do
    # let(:job) { Factory(:job) }
    
    context "new shift" do
        it "has a valid factory" do
            expect(build(:shift)).to be_valid
        end
        it 'is invalid without an job' do
            expect(build(:shift, job_id: nil)).to_not be_valid
        end
        it 'is invalid without an employee' do
            expect(build(:shift, employee_id: nil)).to_not be_valid
        end
        
    end
    context "clock out" do
        it "set time in" do
            subject { create(:shift) }
            expect(subject.time_out).to eq(subject.time_in)
        end
        
        it "clock out" do
            subject { create(:shift) }
            subject.clock_out!
            expect(subject.state).to eq("clocked_out")
            expect(subject.time_out).to be_within(0.1).of(Time.current)
        end
        
        it "#calculate_time" do
            subject { create(:off_shift) }
            expect(subject.time_out).to be_within(0.1).of(Time.current)
        end
    end

end

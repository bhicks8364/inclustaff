# == Schema Information
#
# Table name: jobs
#
#  id               :integer          not null, primary key
#  employee_id      :integer
#  order_id         :integer
#  title            :string
#  description      :string
#  start_date       :date
#  pay_rate         :decimal(, )
#  end_date         :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  active           :boolean
#  deleted_at       :datetime
#  recruiter_id     :integer
#  timesheets_count :integer
#

require 'rails_helper'

RSpec.describe Job, type: :model do
    # let(:job) { Factory(:job) }
    
    context "new job" do
        it "has a valid factory" do
            expect(build(:job)).to be_valid
            # comment1 = post.comments.create!(:body => "first comment")
            # comment2 = post.comments.create!(:body => "second comment")
            # expect(post.reload.comments).to eq([comment2, comment1])
        end
        it 'is invalid without an order' do
            expect(build(:job, order_id: nil)).to_not be_valid
        end
    end

end

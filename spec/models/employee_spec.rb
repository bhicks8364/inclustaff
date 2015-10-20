# == Schema Information
#
# Table name: employees
#
#  id               :integer          not null, primary key
#  first_name       :string
#  last_name        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  email            :string
#  ssn              :string
#  phone_number     :string
#  user_id          :integer
#  deleted_at       :datetime
#  assigned         :boolean
#  resume_id        :string
#  desired_job_type :string
#  desired_shift    :string
#

require 'rails_helper'

RSpec.describe Employee, type: :model do
    # let(:job) { Factory(:job) }
    
    context "new employee" do
        it "has a valid factory" do
            expect(build(:employee)).to be_valid
            # comment1 = post.comments.create!(:body => "first comment")
            # comment2 = post.comments.create!(:body => "second comment")
            # expect(post.reload.comments).to eq([comment2, comment1])
        end
        it 'is invalid without an email' do
            expect(build(:employee, email: nil)).to_not be_valid
        end
    end

end

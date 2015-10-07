# == Schema Information
#
# Table name: invoices
#
#  id         :integer          not null, primary key
#  company_id :integer
#  agency_id  :integer
#  week       :integer
#  due_by     :datetime
#  paid       :boolean
#  total      :decimal(, )
#  amt_paid   :decimal(, )
#  date_paid  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class InvoiceSerializer < ActiveModel::Serializer
  attributes :id, :company_id, :agency_id, :week, :due_by, :paid, :total, :amt_paid, :date_paid
end

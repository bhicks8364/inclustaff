
# == Schema Information
#
# Table name: orders
#
#  id                 :integer          not null, primary key
#  company_id         :integer
#  pay_range          :string
#  notes              :text
#  number_needed      :integer
#  needed_by          :datetime
#  urgent             :boolean
#  active             :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  title              :string
#  deleted_at         :datetime
#  manager_id         :integer
#  jobs_count         :integer
#  account_manager_id :integer
#  mark_up            :decimal(, )
#  agency_id          :integer
#  dt_req             :string
#  bg_check           :string
#  heavy_lifting      :boolean
#  stwb               :boolean
#  est_duration       :string
#  shift              :string
#  bwc_code           :string
#  min_pay            :decimal(, )
#  max_pay            :decimal(, )
#  pay_frequency      :string
#  address            :string
#  latitude           :float
#  longitude          :float
#  aca_type           :string
#

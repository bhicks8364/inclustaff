class AddIpAddressToInquiries < ActiveRecord::Migration
  def change
    add_column :inquiries, :ip_address, :string
  end
end

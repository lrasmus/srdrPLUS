# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  login              :string(255)      not null
#  email              :string(255)      not null
#  fname              :string(255)      not null
#  lname              :string(255)      not null
#  organization       :string(255)      not null
#  user_type          :string(255)      not null
#  crypted_password   :string(255)      not null
#  password_salt      :string(255)      not null
#  persistence_token  :string(255)      not null
#  login_count        :integer          default(0), not null
#  failed_login_count :integer          default(0), not null
#  last_request_at    :datetime
#  current_login_at   :datetime
#  last_login_at      :datetime
#  current_login_ip   :string(255)
#  last_login_ip      :string(255)
#  perishable_token   :string(255)      default(""), not null
#  created_at         :datetime
#  updated_at         :datetime
#

module SRDR
  class User < DbSrdr

  end
end

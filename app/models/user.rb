class User < ActiveRecord::Base
  def self.find_user(email, password)
    find(:all, :conditions => ["email = ? AND password = ?", email, password])
  end
end

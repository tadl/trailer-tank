class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2]
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :provider, :uid, :avatar, :score
  has_many :trailers, :dependent => :nullify
  before_destroy {|user| user.trailers.clear}
def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    extra = access_token.extra.raw_info
    user = User.where(:email => data["email"]).first
    user.avatar = data["image"]
    user.save!
    unless user
      if extra["hd"] == 'tadl.org'
      user = User.create(
             username: data["name"],
             email: data["email"],
             avatar: data["image"],
             password: Devise.friendly_token[0,20],
             score: '0',
            )
      end
      end
    user
end
end


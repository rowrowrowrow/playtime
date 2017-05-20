class User < ApplicationRecord
  validates :email, uniqueness: true, presence: true

  has_many :site_managers
  has_many :wishlists, through: :site_managers

  def self.find_or_create_from_amazon_hash!(hash)
    oauth_info = AmazonOAuthInfo.new(hash)

    find_by_amazon_user_id(oauth_info.amazon_user_id) ||
    find_by_email(oauth_info.email) ||
    create!(
      name:           oauth_info.name,
      email:          oauth_info.email,
      amazon_user_id: oauth_info.amazon_user_id,
      zipcode:        oauth_info.zipcode
    )
  end

  def can_manage?(wishlist)
    admin? || wishlists.find_by_id(wishlist.id)
  end

  class AmazonOAuthInfo
    attr_reader :hash

    def initialize(hash)
      @hash = hash
    end

    def amazon_user_id
      hash["uid"]
    end

    def email
      hash["info"]["email"]
    end

    def name
      hash["info"]["name"]
    end

    def zipcode
      hash["extra"]["postal_code"]
    end
  end
end
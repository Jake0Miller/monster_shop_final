class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :order_items, through: :items
  has_many :orders, through: :order_items
  has_many :users

  validates_presence_of :name,
                        :address,
                        :city,
                        :state,
                        :zip

  DEFAULT_IMAGE = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw"

  def item_count
    items.count
  end

  def average_item_price
    items.average(:price)
  end

  def distinct_cities
    orders.joins('JOIN addresses ON orders.address_id = addresses.id')
          .order('city_state')
          .distinct
          .pluck("CONCAT_WS(', ', addresses.city, addresses.state) AS city_state")
  end

  def pending_orders
    orders.where(status: 'pending')
  end

  def order_items_by_order(order_id)
    order_items.where(order_id: order_id)
  end

  def default_image_items
    items.where(image: DEFAULT_IMAGE)
  end

  def unfulfilled_orders
    order_items.where(fulfilled: false)
               .select('order_items.order_id, sum(order_items.quantity * order_items.price) AS value')
               .group(:order_id)
  end
end

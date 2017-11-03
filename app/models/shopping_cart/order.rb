module ShoppingCart
  class Order < ApplicationRecord
    belongs_to :user, optional: true, class_name: ShoppingCart.user_class.to_s
    belongs_to :delivery, optional: true, class_name: 'ShoppingCart::Delivery'
    belongs_to :coupon, optional: true, class_name: 'ShoppingCart::Coupone'
    belongs_to :credit_card, optional: true, class_name: 'ShoppingCart::CreditCard'

    has_many :order_items, dependent: :destroy
    has_many :products, class_name: ShoppingCart.product_class.to_s, dependent: :destroy

    has_many :addresses, dependent: :destroy
    has_one :billing, dependent: :destroy
    has_one :shipping, dependent: :destroy

    after_create :set_number_and_status

    enum status: %i[in_progress in_queue in_delivery delivered canceled]

    scope :in_progress, -> { where status: %w[in_queue in_delivery] }

    scope :payed,  -> { where.not status: %w[in_progress canceled] }
    scope :placed, -> { where.not(status: %w[in_progress]).order('created_at desc') }

    def place_in_queue
      update(status: 1, completed_at: Time.current)
    end

    def sub_total
      order_items.to_a.sum(&:total)
    end

    def total
      coupon_discount = coupon ? coupon.discount : 0.00
      delivery_price = delivery ? delivery.price : 0.00

      sub_total - coupon_discount + delivery_price
    end

    private

    def set_number_and_status
      update(number: "R#{id.to_s.rjust(8, '0')}", status: 0)
    end
  end
end

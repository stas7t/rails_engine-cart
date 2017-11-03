module ShoppingCart
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    helper_method :current_order

    protected

    def after_sign_in_path_for(resource)
      if cookies[:from_checkout]
        cookies.delete :from_checkout
        main_app.checkout_path(:addresses)
      else
        super
      end
    end

    private

    def current_order
      return Order.new unless session[:order_id]
      Order.find(session[:order_id])
    end
  end
end

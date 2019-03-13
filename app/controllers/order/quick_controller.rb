class Order::QuickController < ApplicationController
  def new
    @order_quick = Order::Quick.new(type_name: params['type_name'], type_id: params[:type_id])
  end

  def create
    phone = params[:phone] || params['order_quick']['phone']
    Order::Quick.prepare(phone)

    @order_quick = Order::Quick.where(phone: phone).first
    if @order_quick.blank?
      @order_quick = Order::Quick.create!(params['order_quick'])
    else
      order_type_set
      passed_time = (300 - (Time.now - @order_quick.updated_at)).round(2)
      if passed_time < 0
        @order_quick.touch
      else
        passed_time = passed_time.divmod 60
        passed_time = "#{passed_time[0]}:#{passed_time[1].to_i.to_s.rjust(2, '0')}"
        @order_quick.errors.add('passed_time'.to_sym, "Повторный код можно запросить через: #{passed_time}.")
      end
    end
  end

  def update
    @order_quick = Order::Quick.where(phone: params[:order_quick][:phone]).first
    if @order_quick.blank?
      render 'update'
    else
      order_type_set

      if @order_quick.code == params[:order_quick][:code_confirm]
        @order_quick.create_order_and_send_email
        @order_quick.destroy
        session.delete(:basket_id)
      else
        @order_quick.errors.add('code_confirm'.to_sym, "Вы ввели неверный код.")
        render action: 'create'
      end
    end
  end

  private

  def order_type_set
    @order_quick.type_name = params[:type_name] || params[:order_quick][:type_name]
    @order_quick.type_id = params[:type_id] || params[:order_quick][:type_id]
  end
end

class Order::Quick < ActiveRecord::Base
  before_save :create_code
  after_save :send_code_by_sms
  after_touch :send_code_by_sms

  attr_accessible :code, :phone, :code_confirm, :type_name, :type_id
  attr_accessor :code_confirm, :type_name, :type_id

  validates :phone, presence: true, format: { with: /\A(8|7)\s?[\s|(]?\d{3}[\s|)]?\s?\d{3}[-|\s]?\d{2}[-|\s]?\d{2}\z/,
                                              message: 'видимо вы ошиблись в написании телефона' }
  validates :code_confirm, format: { with: /\A\d{5}\z/, message: 'видимо вы ошиблись - код 5 цифр' }, on: :update
  validates :code_confirm, presence: true, on: :update

  def self.prepare phone
    phone[0] = '7'
    phone.gsub!(/\s|\(|\)|-/, '')
  end

  def create_order_and_send_email
    current_basket = current_basket_get
    biz_info = ::BizInfo.new

    customer_mail = MailerBasket.prepare(current_basket, { zakaz: true, recepient: true, biz_info:  biz_info })
    customer_mail.deliver if customer_mail

    emails = biz_info&.email_for_form
    emails.split(',').each do |to|
      MailerBasket.prepare(current_basket, { zakaz: true, to: to, biz_info:  biz_info }).deliver
    end
  end

  private

  def create_code
    new_code = nil
    loop do
      new_code = Random.new.rand(99999).to_s.ljust(5, '0')
      break if Order::Quick.where(code: new_code).blank?
    end
    self.code = new_code
  end

  def send_code_by_sms
    Senders::Sms.new("Код: #{self.code}. Введите данный код для подтверждения заказа.", '', phone).send
  end

  def current_basket_get
    if type_name == 'basket'
      @basket = Basket.find(type_id)
      basket_contacts_set
    else
      create_basket
    end
    @basket.save
    @basket
  end

  def create_basket
    @basket = ::Basket.new
    @basket.add_basket_item(type_id)
    basket_contacts_set
  end

  def basket_contacts_set
    @basket.name = 'Покупатель'
    @basket.contacts = phone
    @basket.phone = phone
    @basket.message = 'Заказ в 1 клик'
  end
end

class TovarViewed

  def initialize(session)
    @tovars = if session[:tovar_viewed].nil?
                []
              else
                ar_tovars = []
                session[:tovar_viewed].each do |tovar_id|
                  tovar = Tovar.where(id: tovar_id)
                  if tovar.blank?
                    session[:tovar_viewed].delete(tovar_id)
                  else
                    ar_tovars << tovar.first
                  end
                end
                ar_tovars
              end
  end

  def tovars
    @tovars
  end

  def self.add(sess, id)
    sess ||= []
    sess.delete(id)
    sess.unshift(id)
    sess[0..6]
  end

end

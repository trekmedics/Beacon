module FirstRespondersHelper
  def display_float(percentage)
    return percentage.present? ? percentage.round(4) : '-'
  end
end

require File.expand_path('../config/environment', File.dirname(__FILE__))
require 'csv'

csv = CSV.open("data/wic-all.csv", headers: true)
csv.each do |row|
  phone_number = PhoneNumber.find_or_initialize_by(
    phone_number: PhoneNumberFormatter.format(row["phone_number"])
  )

  sms_deliverable =
    if row["invalid"] == "Y"
      "no"
    else
      "yes"
    end

  wic_opt_in =
    if row["opt_in"] == "Y"
      "yes"
    elsif row["opt_in"] == "N"
      "no"
    else
      "no_response"
    end

  phone_number.update_attributes(
    wic_id: row["wic_id"],
    first_name: row["first_name"].titlecase,
    last_name: row["last_name"].titlecase,
    wic_opt_in: wic_opt_in,
    sms_deliverable: sms_deliverable
  )
end

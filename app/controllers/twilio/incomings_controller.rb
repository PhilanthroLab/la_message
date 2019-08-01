module Twilio
  class IncomingsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      contact = Contact.find_by(
        "phone_number = ? OR phone_number = ?",
        params["From"],
        params["From"].gsub("+1", "")
      )

      message = Message.create!(
        contact: contact,
        from_phone_number: params["From"],
        to_phone_number: params["To"],
        body: incoming_text_and_images,
        inbound: true
      )

      return if contact.blank?

      last_message_type = contact.messages.where.not(message_type: nil).order(created_at: :desc).first&.message_type
      return if last_message_type.blank?

      campaign_message = last_message_type.constantize.new(contact)
      campaign_message.on_reply(message)
    end

    private

    def incoming_text_and_images
      incoming_message = params.fetch("Body", "").strip.tr("\0", " ").presence || "(no content)"
      number_of_images = params["NumMedia"].to_i
      number_of_images.times do |i|
        twilio_image_url = params["MediaUrl#{i}"]
        incoming_message << " " + twilio_image_url
      end
      incoming_message
    end
  end
end
# frozen_string_literal: true

module NotificationServices
  class WebhookService < NotificationService
    LABEL = "webhook"
    FIELDS = [
      [:api_token, {
        placeholder: "URL to receive a POST request when an error occurs",
        label: "URL"
      }]
    ]

    def check_params
      if FIELDS.detect { |f| self[f[0]].blank? }
        errors.add :base, "You must specify the URL"
      end
    end

    def message_for_webhook(problem)
      {
        content: build_discord_message(problem)
      }
    end

    def create_notification(problem)
      HTTParty.post(api_token, headers: {"Content-Type" => "application/json", "User-Agent" => "Errbit"}, body: message_for_webhook(problem).to_json)
    end

    private
      def build_discord_message(problem)
        <<~MSG
          **Class:** #{problem.error_class}
          **Message:** #{problem.message}
          **Where:** #{problem.where.presence}
          **URL:** #{problem.url}
        MSG
      end
  end
end

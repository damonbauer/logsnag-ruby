# frozen_string_literal: true

module LogSnag
  Result = Struct.new(:success, :data, :error_message, :status_code, keyword_init: true) do
    def success?
      success
    end

    def error?
      !success
    end
  end
end

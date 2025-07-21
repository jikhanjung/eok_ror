class SttService
  include HTTParty

  def initialize
    @base_uri = ENV['STT_API_BASE_URL'] || 'https://api.example.com'
    @api_key = ENV['STT_API_KEY'] || 'your-api-key'
  end

  def transcribe(audio_url, answer_id:)
    # This is a placeholder implementation
    # Replace with actual STT service integration (e.g., Naver CLOVA Speech, OpenAI Whisper)
    
    options = {
      headers: {
        'Authorization' => "Bearer #{@api_key}",
        'Content-Type' => 'application/json'
      },
      body: {
        audio_url: audio_url,
        callback_url: webhook_url,
        answer_id: answer_id,
        language: 'ko-KR'
      }.to_json
    }

    response = HTTParty.post("#{@base_uri}/transcribe", options)
    
    if response.success?
      response.parsed_response
    else
      raise "STT API Error: #{response.code} - #{response.message}"
    end
  end

  private

  def webhook_url
    Rails.application.routes.url_helpers.api_stt_webhook_url(host: ENV['APP_HOST'] || 'localhost:3000')
  end
end
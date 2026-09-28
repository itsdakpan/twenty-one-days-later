require 'net/http'
require 'json'

class QuotesController < ApplicationController
  def random
    quote = Rails.cache.fetch("zenquote/#{Date.current}", expires_in: 12.hours) do
      uri = URI("https://zenquotes.io/api/today")
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 3, read_timeout: 3) do |http|
        http.get(uri.request_uri)
      end
      data = JSON.parse(response.body)
      { quote: data[0]["q"], author: data[0]["a"] }
    end

    render json: quote
  rescue StandardError
    render json: { error: "Failed to load quote" }, status: :service_unavailable
  end
end

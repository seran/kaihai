class FtsQuery
  TOKEN_PATTERN = /[\p{Alnum}_]+/

  def self.build(input)
    tokens = input.to_s.scan(TOKEN_PATTERN)
    return "" if tokens.empty?

    tokens.map { |token| %("#{token}"*) }.join(" ")
  end
end

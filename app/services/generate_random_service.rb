require 'httparty'

response = HTTParty.post(
  "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=#{ENV['API_KEY']}",
  headers: { 'Content-Type' => 'application/json' },
  body: {
    contents: [
      {
        role: "user",
        parts: [{ text: "Give me array only with 5 titles of books which I can also like if I read #{book_titles_str}?" }]
      }
    ]
  }
)

# Обработка ответа
if response.success?
  # Успешный ответ, обработать JSON-данные
  result = JSON.parse(response.body)
  puts result
else
  # Обработка ошибки
  puts "Ошибка при запросе: #{response.code}"
  puts response.body
end

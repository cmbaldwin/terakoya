module Terakoya
  class MotivationalQuote
    QUOTES = [
      {
        text: 'Negativity is the enemy of creativity',
        author: 'David Lynch'
      },
      {
        text: "Take two stone tablets, on one of them carve 'Problems are Inevitable,' and on the other carve 'Problems are soluble'.",
        author: 'David Deutsch'
      }
    ].freeze

    def self.random
      QUOTES.sample
    end
  end
end

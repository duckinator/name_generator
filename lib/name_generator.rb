require "name_generator/version"

module NameGenerator
  LETTERS = ("a".."z").to_a
  ACCEPTABLE_AFTER =
    begin
      # I have no idea how correct these are, I'm just bullshitting it
      # based on what sounds good to me.
      az = LETTERS
      vowels = %w[a e i o u]
      consonants = az - vowels

      aa = {}
      aa[/[aeiou]/] = consonants
      aa[/c/]     = "ckaeiou"
      aa[/[bdfk]/]  = "aeiou"
      aa[/[bcdfghjklmnpqrstvwxyz]/] = vowels

      aa
    end.freeze

  def self.call(options)
    min_length = options["min_length"]
    max_length = options["max_length"]

    length = rand(min_length..max_length)
    result = ""

    while result.length < length
      current = LETTERS.sample

      if options["debug"]
        puts "can_follow?(#{result[-1].inspect}, #{current.inspect}) #=> #{can_follow?(result[-1], current)}"
      end

      if result.empty? || can_follow?(result[-1], current)
        result << current
      elsif options["debug"]
        warn "Cannot append #{current} to #{result}."
      end
    end

    result
  end

  def self.can_follow?(previous, current)
    ACCEPTABLE_AFTER.any? { |regex, value|
      (previous =~ regex) && value.include?(current)
    }
  end
  private_class_method :can_follow?
end

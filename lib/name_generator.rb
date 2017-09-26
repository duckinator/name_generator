require "name_generator/version"

module NameGenerator
  NameTooShort = Class.new(StandardError)

  LETTERS = ("a".."z").to_a
  ACCEPTABLE_AFTER =
    begin
      # I have no idea how correct these are, I'm just bullshitting it
      # based on what sounds good to me.
      az = LETTERS
      vowels = %w[a e i o u]
      consonants = az - vowels

      l = ->(str) { str.split("") }

      aa = {
        /[aeiou]/ => consonants,
        /a/ => l.("bcdefgilmnoprstvwxz"),
        /b/ => vowels,
        /c/ => l.("hkaeiou"),
        /d/ => vowels,
        /e/ => l.("ae"),
        /f/ => l.("aefilou"),
        /g/ => l.("aehiou"),
        /h/ => vowels,
        /i/ => l.("bcdefgklmnopqrstvxz"),
        /j/ => vowels,
        /k/ => vowels,
        /l/ => vowels + ["l"],
        /m/ => vowels + ["m"],
        /n/ => vowels + ["n"],
        /o/ => l.("aiou"),
        /p/ => vowels + ["p"],
        /q/ => ["u"],
        /r/ => vowels + l.("bcdfgklmnpqrstvy"),
        /s/ => vowels + l.("lmst"),
        /t/ => vowels + ["c"],
        /u/ => vowels + l.("bcdfgimrstv"),
        /v/ => vowels,
        /w/ => vowels,
        /x/ => vowels,
        /y/ => nil,
        /z/ => nil,
      }

      aa
    end.freeze

  def self.call(options)
    min_length = options["min_length"]
    max_length = options["max_length"]

    length = rand(min_length..max_length)
    result = ""

    while result.length < length
      current = LETTERS.sample

      # Break if nothing can follow.
      break if !result.empty? && LETTERS.all? { |l| !can_follow?(result[-1], l) }

      if options["debug"]
        puts "can_follow?(#{result[-1].inspect}, #{current.inspect}) #=> #{can_follow?(result[-1], current)}"
      end

      if result.empty? || can_follow?(result[-1], current)
        result << current
      elsif options["debug"]
        warn "Cannot append #{current} to #{result}."
      end
    end

    # HACK: Yes, this is very gross.
    raise NameTooShort if result.length < min_length

    result
  rescue NameTooShort
    if options[:debug]
      warn "#{result.inspect} is too short and cannot be expanded; retrying."
    end

    retry
  end

  def self.can_follow?(previous, current)
    ACCEPTABLE_AFTER.any? { |regex, value|
      (previous =~ regex) && value && value.include?(current)
    }
  end
  private_class_method :can_follow?
end

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
        /^$/      => az,
        /[aeiou]$/ => consonants,
        /b$/     => vowels,
        /^c$/    => l.("haeiou"),
        /^.c$/   => l.("hkaeiou"),
        /d$/     => vowels,
        /[^aeiou]e$/ => l.("ae"),

        /^f$/    => vowels + l.("fl"),
        /ff$/    => vowels + ["l"],
        /[^rf]f$/ => vowels + l.("fl"),

        /g$/ => l.("aehiou"),
        /h$/ => vowels,
        /i$/ => l.("bcdefgklmnopqrstvxz"),
        /j$/ => vowels,
        /k/  => vowels,

        # l can be followed by vowels always, or l if it's preceded by a vowel.
        /^l$/   => vowels,
        /^[aeiou]l$/ => vowels + ["l"],

        /(^|m)$/ => vowels,
        /[^m]m$/ => vowels + ["m"],

        /(^|n)n$/ => vowels,
        /[^n]n$/ => vowels + ["n"],

        /[^aeiou]o$/ => consonants + l.("aou"),
        /^[aeiou]o$/ => consonants,

        /p$/ => vowels + ["p"],
        /q$/ => ["u"],

        # r can only be followed by vowels if it's the first letter.
        /^r$/ => vowels,
        /.r$/ => vowels + l.("bcdfgklmnpqrstvy"),

        # no double-s at the start of words.
        /^s$/ => vowels + l.("hlmt"),
        /ss$/ => vowels,
        /^[^s]s$/ => vowels + l.("hlmt"),

        /^t$/ => vowels,
        /.t$/ => vowels + ["c"],

        /u$/ => vowels + l.("bcdfgimrstv"),
        /v$/ => vowels,
        /w$/ => vowels,
        /x$/ => vowels,
        /y$/ => nil,
        /z$/ => nil,
      }

      aa
    end.freeze

  def self.call(options)
    min_length = Integer(options["min_length"])
    max_length = Integer(options["max_length"])

    length = rand(min_length..max_length)
    result = ""

    while result.length < length
      valid = LETTERS.select { |l| can_follow?(result, l) }
      current = valid.sample

      # Break if nothing can follow.
      break if !result.empty? && valid.empty?

      if options["debug"]
        puts "can_follow?(#{result.inspect}, #{current.inspect}) #=> #{can_follow?(result[-1], current)}"
      end

      if result.empty? || can_follow?(result, current)
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

  def self.can_follow?(result, current)
    ACCEPTABLE_AFTER.any? { |regex, value|
      (result =~ regex) && value && value.include?(current)
    }
  end
  private_class_method :can_follow?
end

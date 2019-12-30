require "name_generator/version"

module NameGenerator
  Retry = Class.new(Exception)

  # These don't sound great at the end of a name.
  UNWANTED_ENDINGS = %w[
    ae
    ai
    ao
    au
    qu
    pp
  ]

  LETTERS = ("a".."z").to_a
  VOWELS = %w[a e i o u]
  CONSONANTS = LETTERS - VOWELS
  ACCEPTABLE_AFTER =
    begin
      l = ->(str) { str.split("") }

      aa = {
        /^$/        => LETTERS,
        /^[#{VOWELS}]$/     => CONSONANTS,
        /^[#{CONSONANTS}]$/ => VOWELS,
        /b$/        => VOWELS,
        /^c$/       => %w[h   a e i o u],
        /^.c$/      => %w[h k a e i o u],
        /d$/        => VOWELS,
        /[^#{VOWELS}]e$/ => %w[a e],

        /^f$/       => VOWELS + %w[  l],
        /ff$/       => VOWELS + %w[  l],
        /[^rf]f$/   => VOWELS + %w[f l],

        /g$/        => %w[h a e i o u],
        /h$/        => VOWELS + ["y"],
        /i$/        => LETTERS - %w[a h i j u y],

        /j$/        => VOWELS,

        # TODO: Is this supposed to be anchored (e.g. ^k or $k)?
        /k/         => VOWELS,

        # l can be followed by VOWELS always, or l if it's preceded by a vowel.
        /^l$/       => VOWELS,
        /^[aeiou]l$/ => VOWELS + ["l"],

        /^m$/       => VOWELS,
        /mm$/       => VOWELS,
        /[^m]m$/    => VOWELS + ["m"],

        /(^|n)n$/   => VOWELS,
        /[^n]n$/    => VOWELS + ["n"],

        /[^aeiou]o$/ => CONSONANTS + %w[a o u],
        /^[aeiou]o$/ => CONSONANTS,

        /p$/ => VOWELS + %w[p],
        /q$/ => %w[u],

        # r can be followed only by VOWELS if it's the first letter.
        /^r$/ => VOWELS,
        /.r$/ => LETTERS - %w[h j z],

        # s can be followed only by VOWELS if it's the first letter.
        /^s$/     => VOWELS + l.("hlmt"),
        /ss$/     => VOWELS,
        /^[^s]s$/ => VOWELS + l.("hlmt"),

        /^t$/ => VOWELS,
        /.t$/ => VOWELS + ["c"],

        /u$/ => VOWELS + l.("bcdfgimrstv"),
        /v$/ => VOWELS,
        /w$/ => VOWELS,
        /x$/ => VOWELS,
        /y$/ => nil,
        /z$/ => nil,
      }

      aa
    end.freeze

  def self.call(options)
    min_length = Integer(options["min_length"])
    max_length = Integer(options["max_length"])

    length = rand(min_length..max_length)
    result = options["seed"] || ""

    loop do
      break if result.length >= length

      valid = LETTERS.select { |l| can_follow?(result, l) }
      break if valid.nil?

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

      # 25% chance if breaking the loop if we've met or exceeded min_length
      # and the current name is valid.
      break if rand(1..100) <= 25 && length >= min_length && valid_name?(name)
    end

    # HACK: Yes, this is very gross.
    if result.length < min_length
      warn "#{result.inspect} is too short; retrying." if options[:debug]
      raise Retry
    end

    if !valid_name?(result)
      warn "#{result.inspect} is an invalid name; retrying." if options[:debug]
      raise Retry
    end

    result
  rescue Retry
    retry
  end

  def self.can_follow?(result, current)
    ACCEPTABLE_AFTER.any? { |regex, value|
      (result =~ regex) && value && value.include?(current)
    }
  end
  private_class_method :can_follow?

  def self.valid_name?(name)
    UNWANTED_ENDINGS.none? { |ending| name.end_with?(ending) }
  end
  private_class_method :valid_name?
end

# frozen_string_literal: true

# Provides alternation
# when one of the passed in patterns is accepted, this pattern is accepted
class OneOfPattern < PatternBase
    # create a new OneOfPattern
    # this is expects an array of patterns

    #
    # Create a new OneOfPattern
    #
    # @param [Array<PatternBase,Regexp,String>] patterns a list of patterns to match
    #
    def initialize(patterns, deep_clone = nil, original_arguments = nil)
        if deep_clone == :deep_clone
            super(patterns, deep_clone, original_arguments)
            return
        end
        unless patterns.is_a? Array
            puts <<-HEREDOC.remove_indent
                oneOf() expects an array of patterns, the provided argument is not an array.
                The arguments to oneOf is below
                #{patterns}
            HEREDOC
        end
        super(
            match: "one of",
            patterns: patterns.map do |pattern|
                next pattern if pattern.is_a? PatternBase

                PatternBase.new(pattern)
            end
        )
    end

    # (see PatternBase#do_evaluate_self)
    def do_evaluate_self(groups)
        patterns_strings = @arguments[:patterns].map do |pattern|
            regex = pattern.evaluate(groups)
            next regex if pattern.single_entity?

            "(?:#{regex})"
        end

        return "(#{patterns_strings.join '|'})" if needs_to_capture?

        "(?:#{patterns_strings.join '|'})"
    end

    # (see PatternBase#do_collect_self_groups)
    def do_collect_self_groups(next_group)
        groups = []
        @arguments[:patterns].each do |pattern|
            pat_groups = pattern.collect_group_attributes(next_group)
            groups.concat(pat_groups)
            next_group += pat_groups.length
        end
        groups
    end

    # (see PatternBase#single_entity?)
    # @return [true]
    def single_entity?
        true
    end

    # (see PatternBase#map!)
    def map!(map_includes = false, &block)
        @arguments[:patterns].map! { |p| p.map!(map_includes, &block) }
        @next_pattern.map!(map_includes, &block) if @next_pattern.is_a? PatternBase
        map_includes!(&block) if map_includes
        self
    end

    # (see PatternBase#to_s)
    def to_s(depth = 0, top_level = true)
        indent = "  " * depth
        output = top_level ? "oneOf([" : ".oneOf(["
        output += "\n#{indent}  "
        output += (@arguments[:patterns].map do |pattern|
            pattern.to_s(depth + 1, true).lstrip
        end).join ",\n#{indent}  "
        output += "\n#{indent}])"
        output += @next_pattern.to_s(depth, false).lstrip if @next_pattern
        output
    end
end

class PatternBase
    #
    # Match one of the supplied patterns
    #
    # @param [Array<PatternBase,Regexp,String>] patterns a list of patterns to match
    #
    # @return [PatternBase] a pattern to append to
    #
    def oneOf(patterns)
        insert(OneOfPattern.new(patterns))
    end
end

#
# (see PatternBase#oneOf)
#
def oneOf(patterns)
    OneOfPattern.new(patterns)
end

#
# Implements back references
# for some group N whose reference is "foo"
# matchResultOf("foo") results in the pattern /\N/
#
class BackReferencePattern < PatternBase
    def initialize(reference, deep_clone = nil, original_arguments = nil)
        if reference.is_a? String
            super(
                match: Regexp.new("(?#[:backreference:#{reference}:])"),
                backreference_key: reference
            )
        else
            # most likely __deep_clone__ was called, just call the super initializer
            super(reference, deep_clone, original_arguments)
        end
    end

    # (see PatternBase#to_s)
    def to_s(depth = 0, top_level = true)
        output = top_level ? "matchResultOf(" : ".matchResultOf("
        output += "\"#{@arguments[:backreference_key]}\")"
        output += @next_pattern.to_s(depth, false).lstrip if @next_pattern
        output
    end

    # (see PatternBase#single_entity?)
    # @return [true]
    def single_entity?
        true
    end

    # (see PatternBase#self_scramble_references)
    def self_scramble_references
        scramble = lambda do |name|
            return name if name.start_with?("__scrambled__")

            "__scrambled__" + name
        end

        key = @arguments[:subroutine_key]
        scrambled = scramble.call(key)

        @match = @match.sub(key, scrambled)
        @arguments[:subroutine_key] = scrambled
    end
end

class PatternBase
    #
    # Match the result of some other pattern
    #
    # @param [String] reference a reference to match the result of
    #
    # @return [PatternBase] a pattern to append to
    #
    def matchResultOf(reference)
        insert(BackReferencePattern.new(reference))
    end
end

# (see PatternBase#matchResultOf)
def matchResultOf(reference)
    BackReferencePattern.new(reference)
end

#
# Implements subexp calls
# for some group N whose reference is "foo"
# recursivelyMatch("foo") results in the pattern /\gN/
#
class SubroutinePattern < PatternBase
    def initialize(reference, deep_clone = nil, original_arguments = nil)
        if reference.is_a? String
            super(
                match: Regexp.new("(?#[:subroutine:#{reference}:])"),
                subroutine_key: reference
            )
        else
            # most likely __deep_clone__ was called, just call the super initializer
            super(reference, deep_clone, original_arguments)
        end
    end

    # (see PatternBase#to_s)
    def to_s(depth = 0, top_level = true)
        output = top_level ? "recursivelyMatch(" : ".recursivelyMatch("
        output += "\"#{@arguments[:subroutine_key]}\")"
        output += @next_pattern.to_s(depth, false).lstrip if @next_pattern
        output
    end

    # (see PatternBase#single_entity?)
    # @return [true]
    def single_entity?
        true
    end

    # (see PatternBase#self_scramble_references)
    def self_scramble_references
        scramble = lambda do |name|
            return name if name.start_with?("__scrambled__")

            "__scrambled__" + name
        end

        key = @arguments[:subroutine_key]
        scrambled = scramble.call(key)

        @match = @match.sub(key, scrambled)
        @arguments[:subroutine_key] = scrambled
    end

    #
    # SubroutinePattern can cause its capture groups to be rematched
    #
    # @return [true] rematching is possible
    #
    def self_capture_group_rematch
        true
    end
end

class PatternBase
    #
    # Recursively match some outer pattern
    #
    # @param [String] reference a reference to an outer pattern
    #
    # @return [PatternBase] a PatternBase to append to
    #
    def recursivelyMatch(reference)
        insert(SubroutinePattern.new(reference))
    end
end

# (see PatternBase#recursivelyMatch)
def recursivelyMatch(reference)
    SubroutinePattern.new(reference)
end

#
# Implements using a pattern that has not been defined
#
class PlaceholderPattern < PatternBase
    #
    # Constructs a new placeholder pattern
    # @overload initialize(placeholder)
    #   @param [Symbol] placeholder the name to replace with
    #
    # @overload initialize(opts, deep_clone, original)
    #   @param (see PatternBase#initialize)
    #
    def initialize(placeholder, deep_clone = nil, original_arguments = nil)
        if deep_clone == :deep_clone
            super(placeholder, deep_clone, original_arguments)
        else
            super(
                match: Regexp.new("placeholder(?##{placeholder})"),
                placeholder: placeholder
            )
        end
    end

    # (see PatternBase#to_s)
    def to_s(depth = 0, top_level = true)
        return super unless @match == "placeholder"

        output = top_level ? "placeholder(" : ".placeholder("
        output += ":#{@arguments[:placeholder]})"
        output += @next_pattern.to_s(depth, false).lstrip if @next_pattern
        output
    end

    # (see PatternBase#to_tag)
    # @note this raises a runtime error if the pattern has not been resolved
    def to_tag
        if @match.is_a?(String) && @match.start_with?("placeholder")
            placeholder = @arguments[:placeholder]
            raise "Attempting to create a tag from an unresolved placeholder `:#{placeholder}'"
        end

        super()
    end

    # (see PatternBase#evaluate)
    # @note this raises a runtime error if the pattern has not been resolved
    def evaluate(groups = nil)
        if @match.is_a?(String) && @match.start_with?("placeholder")
            raise "Attempting to evaluate an unresolved placeholder `:#{@arguments[:placeholder]}'"
        end

        super(groups)
    end

    #
    # Resolves the placeholder
    #
    # @param [Hash] repository the repository to use to resolve the placeholder
    #
    # @return [self]
    #
    def resolve!(repository)
        unless repository[@arguments[:placeholder]].is_a? PatternBase
            raise ":#{@arguments[:placeholder]} is not a pattern and cannot be substituted"
        end

        @match = repository[@arguments[:placeholder]].__deep_clone__
        self
        # repository[@arguments[:placeholder]].resolve(repository)
    end
end

class PatternBase
    #
    # Match a pattern that does not exist yet
    #
    # @param [Symbol] placeholder the name of the pattern to match
    #
    # @return [PatternBase] a pattern to append to
    #
    def placeholder(placeholder)
        insert(PlaceholderPattern.new(placeholder))
    end

    #
    # Resolves any placeholder patterns
    #
    # @param [Hash] repository the repository to resolve patterns with
    #
    # @return [PatternBase] a copy of self with placeholders resolved
    #
    def resolve(repository)
        __deep_clone__.map!(true) { |s| s.resolve!(repository) if s.respond_to? :resolve! }.freeze
    end
end

# (see PatternBase#placeholder)
def placeholder(placeholder)
    PlaceholderPattern.new(placeholder)
end
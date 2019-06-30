require_relative '../../../directory'
require_relative PathFor[:repo_helper]
require_relative PathFor[:textmate_tools]
require_relative PathFor[:sharedPattern]["numeric"]
require_relative './tokens.rb'

# 
# Setup grammar
# 
    Dir.chdir __dir__
    # reference https://perldoc.perl.org/perlvar.html
    original_grammar = JSON.parse(IO.read("original.tmlanguage.json"))
    Grammar.convertSpecificIncludes(json_grammar: original_grammar, convert:["$self", "$base"], into: :$initial_context)
    grammar = Grammar.new(
        name: original_grammar["name"],
        scope_name: original_grammar["scopeName"],
        version: "",
        information_for_contributors: [
            "This code was auto generated by a much-more-readble ruby file",
            "see https://github.com/jeff-hykin/cpp-textmate-grammar/blob/master",
        ],
    )
# 
# utils
# 
    # NOTE: this pattern can match 0-spaces so long as its still a word boundary
    std_space = newPattern(
        newPattern(
            at_least: 1,
            quantity_preference: :as_few_as_possible,
            match: newPattern(
                    match: @spaces,
                    dont_back_track?: true
                )
        # zero length match
        ).or(
            /\b/.or(
                lookBehindFor(/\W/)
            ).or(
                lookAheadFor(/\W/)
            ).or(
                @start_of_document
            ).or(
                @end_of_document
            )
        )
    )
#
#
# Contexts
#
#
    grammar[:$initial_context] = [
            :using_statement,
            :numbers,
            :special_vars,
            :operators,
            :punctuation,
            # import all the original patterns
            *original_grammar["patterns"],
        ]
#
#
# Patterns
#
#
    # 
    # numbers
    # 
        grammar[:numbers] = numeric_constant(separator:"_")
    # 
    # builtins
    # 
        grammar[:special_vars] = [
            newPattern(
                match: /\$\^[A-Z^_?\[\]]/,
                tag_as: "variable.language.special.caret"
            ),
        ]
            
    # 
    # operators
    # 
        grammar[:operators] = [
            newPattern(
                match: @tokens.that(:areComparisionOperators),
                tag_as: "keyword.operator.comparision",
            ),
            newPattern(
                match: @tokens.that(:areAssignmentOperators),
                tag_as: "keyword.operator.assignment",
            ),
        ]
    # 
    # punctuation
    # 
        grammar[:punctuation] = [
            grammar[:semicolon] = newPattern(
                match: /;/,
                tag_as: "punctuation.terminator.statement"
            ),
        ]
    # 
    # imports
    # 
        grammar[:using_statement] = PatternRange.new(
            tag_as: "meta.import",
            start_pattern: newPattern(
                newPattern(
                    match: /use/,
                    tag_as: "keyword.other.use"
                ).then(std_space).then(
                    match: /\w+/,
                    tag_as: "entity.name.package",
                )
            ),
            end_pattern: grammar[:semicolon],
            includes: []
        )
    # 
    # copy over all the repos
    # 
        for each_key, each_value in original_grammar["repository"]
            grammar[each_key.to_sym] = each_value
        end
 
# Save
saveGrammar(grammar)
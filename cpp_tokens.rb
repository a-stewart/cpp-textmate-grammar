require_relative './readable_regex.rb'
include GrammarHelper

# 
# C++ specific tokens
# 

adjectives = [
    :isOperator,
    :isWordish,
    :isOperatorAlias,
    :canAppearAfterOperatorKeyword,
    :isPostFixOperator,
    :isPreFixOperator,
    :isInFixOperator,
    :evaledLeftToRight,
    :evaledRightToLeft,
    :presedence,
    :isControlFlow,
    :isLogicicalOperator,
    :isAssignmentOperator,
    :isComparisionOperator,
    :isUrnaryOperator,
    :isBinaryOperator,
    :isTernaryOperator,
    :requiresParentheseBlockImmediately,
    :isExceptionRelated,
    :isPrimitive,
    :isType,
    :isLiteral,
    :isTypeCreator,
    :isGenericTypeModifier,
    :isLeftHandSideTypeModifier,
    :isSpecifier,
    :isLambdaSpecifier,
    :isAccessSpecifier,
]

tokens = [
    # operators
    { representation: "::"                   , name: "scope-resolution"               , isOperator: true,                                      isBinaryOperator:  true, presedence:  1   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "++"                   , name: "post-increment"                 , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  2.1 , evaledLeftToRight: true, isPostFixOperator: true },
    { representation: "--"                   , name: "post-decrement"                 , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  2.1 , evaledLeftToRight: true, isPostFixOperator: true },
    { representation: "()"                   , name: "function-call"                  , isOperator: true, canAppearAfterOperatorKeyword: true,                          presedence:  2.3 , evaledLeftToRight: true,                         },
    { representation: "[]"                   , name: "subscript"                      , isOperator: true, canAppearAfterOperatorKeyword: true,                          presedence:  2.4 , evaledLeftToRight: true,                         },
    { representation: "."                    , name: "object-accessor"                , isOperator: true,                                      isBinaryOperator:  true, presedence:  2.5 , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "->"                   , name: "pointer-accessor"               , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  2.5 , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "++"                   , name: "pre-increment"                  , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.1 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "--"                   , name: "pre-decrement"                  , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.1 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "+"                    , name: "plus"                           , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.2 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "-"                    , name: "minus"                          , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.2 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "!"                    , name: "logic-not"                      , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.3 , evaledRightToLeft: true, isPreFixOperator:  true , isLogicicalOperator: true },
    { representation: "not"                  , name: "logic-not-word"                 , isOperator: true,                                      isUrnaryOperator:  true, presedence:  3.3 , evaledRightToLeft: true, isPreFixOperator:  true , isLogicicalOperator: true, isOperatorAlias: true },
    { representation: "~"                    , name: "bitwise-not"                    , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.3 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "compl"                , name: "bitwise-not-word"               , isOperator: true,                                      isUrnaryOperator:  true, presedence:  3.3 , evaledRightToLeft: true, isPreFixOperator:  true , isOperatorAlias: true},
    { representation: "*"                    , name: "dereference"                    , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.5 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "&"                    , name: "address-of"                     , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.6 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "sizeof"               , name: "sizeof"                         , isOperator: true,                                      isUrnaryOperator:  true, presedence:  3.7 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "sizeof..."            , name: "variadic-sizeof"                , isOperator: true,                                      isUrnaryOperator:  true, presedence:  3.7 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "new"                  , name: "new"                            , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.8 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "new[]"                , name: "new-array"                      , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.8 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "delete"               , name: "delete"                         , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.9 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: "delete[]"             , name: "delete-array"                   , isOperator: true, canAppearAfterOperatorKeyword: true, isUrnaryOperator:  true, presedence:  3.9 , evaledRightToLeft: true, isPreFixOperator:  true },
    { representation: ".*"                   , name: "object-accessor-dereference"    , isOperator: true,                                      isBinaryOperator:  true, presedence:  4   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "->*"                  , name: "pointer-accessor-dereference"   , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  4   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "*"                    , name: "multiplication"                 , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  5   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "/"                    , name: "division"                       , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  5   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "%"                    , name: "modulus"                        , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  5   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "+"                    , name: "addition"                       , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  6   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "-"                    , name: "subtraction"                    , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  6   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "<<"                   , name: "bitwise-shift-left"             , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  7   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: ">>"                   , name: "bitwise-shift-right"            , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  7   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "<=>"                  , name: "three-way-compare"              , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  8   , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: "<"                    , name: "less-than"                      , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  9.1 , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: "<="                   , name: "less-than-or-equal-to"          , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  9.1 , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: ">"                    , name: "greater-than"                   , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  9.2 , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: ">="                   , name: "greater-than-or-equal-to"       , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence:  9.2 , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: "=="                   , name: "equal-to"                       , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 10   , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: "!="                   , name: "not-equal-to"                   , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 10   , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true},
    { representation: "not_eq"               , name: "not-equal-to-word"              , isOperator: true,                                      isBinaryOperator:  true, presedence: 10   , evaledLeftToRight: true, isInFixOperator:   true , isComparisionOperator: true, isOperatorAlias: true,},
    { representation: "&"                    , name: "bitwise-and"                    , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 11   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "bitand"               , name: "bitwise-and-word"               , isOperator: true,                                      isBinaryOperator:  true, presedence: 11   , evaledLeftToRight: true, isInFixOperator:   true , isOperatorAlias: true},
    { representation: "^"                    , name: "bitwise-xor"                    , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 12   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "xor"                  , name: "bitwise-xor-word"               , isOperator: true,                                      isBinaryOperator:  true, presedence: 12   , evaledLeftToRight: true, isInFixOperator:   true , isOperatorAlias: true},
    { representation: "|"                    , name: "bitwise-or"                     , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 13   , evaledLeftToRight: true, isInFixOperator:   true },
    { representation: "bitor"                , name: "bitwise-or-word"                , isOperator: true,                                      isBinaryOperator:  true, presedence: 12   , evaledLeftToRight: true, isInFixOperator:   true , isOperatorAlias: true},
    { representation: "&&"                   , name: "logical-and"                    , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 14   , evaledLeftToRight: true, isInFixOperator:   true , isLogicicalOperator: true},
    { representation: "and"                  , name: "logical-and-word"               , isOperator: true,                                      isBinaryOperator:  true, presedence: 14   , evaledLeftToRight: true, isInFixOperator:   true , isLogicicalOperator: true, isOperatorAlias: true},
    { representation: "||"                   , name: "logical-or"                     , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 15   , evaledLeftToRight: true, isInFixOperator:   true , isLogicicalOperator: true},
    { representation: "or"                   , name: "logical-or-word"                , isOperator: true,                                      isBinaryOperator:  true, presedence: 15   , evaledLeftToRight: true, isInFixOperator:   true , isLogicicalOperator: true, isOperatorAlias: true},
    { representation: "?:"                   , name: "ternary-conditional"            , isOperator: true,                                      isTernaryOperator: true, presedence: 16.1 , evaledRightToLeft: true,                         },
    { representation: "throw"                , name: "throw"                          , isOperator: true,                                      isUrnaryOperator:  true, presedence: 16.2 , evaledRightToLeft: true, isPreFixOperator:  true , isControlFlow: true, isExceptionRelated: true},
    { representation: "="                    , name: "direct-assignment"              , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.3 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "+="                   , name: "addition-assignment"            , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.4 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "-="                   , name: "subtraction-assignment"         , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.4 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "*="                   , name: "multiplication-assignment"      , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.5 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "/="                   , name: "division-assignment"            , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.5 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "%="                   , name: "modulus-assignment"             , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.5 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "<<="                  , name: "bitwise-shift-left-assignment"  , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.6 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: ">>="                  , name: "bitwise-shift-right-assignment" , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.6 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "&="                   , name: "bitwise-and-assignment"         , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "and_eq"               , name: "bitwise-and-assignment-word"    , isOperator: true,                                      isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true , isOperatorAlias: true},
    { representation: "^="                   , name: "bitwise-xor-assignment"         , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "xor_eq"               , name: "bitwise-xor-assignment-word"    , isOperator: true,                                      isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true , isOperatorAlias: true},
    { representation: "|="                   , name: "bitwise-or-assignment"          , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true },
    { representation: "or_eq"                , name: "bitwise-or-assignment-word"     , isOperator: true,                                      isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true , isAssignmentOperator: true , isOperatorAlias: true},
    { representation: ","                    , name: "comma"                          , isOperator: true, canAppearAfterOperatorKeyword: true, isBinaryOperator:  true, presedence: 16.7 , evaledRightToLeft: true, isInFixOperator:   true },
    # no presedence
    { representation: "alignof"              , name: "alignof"                        , isOperator: true,                                                                                                           isPreFixOperator:  true },
    { representation: "alignas"              , name: "alignas"                        , isOperator: true,                                                                                                           isPreFixOperator:  true },
    { representation: "typeid"               , name: "typeid"                         , isOperator: true,                                                                                                           isPreFixOperator:  true },
    { representation: "noexcept"             , name: "noexcept"                       , isOperator: true },
    { representation: "static_cast"          , name: "static_cast"                    , isOperator: true },
    { representation: "dynamic_cast"         , name: "dynamic_cast"                   , isOperator: true },
    { representation: "const_cast"           , name: "const_cast"                     , isOperator: true },
    { representation: "reinterpret_cast"     , name: "reinterpret_cast"               , isOperator: true },
    # control
    { representation: "while"                , name: "while"                          , isControlFlow: true, requiresParentheseBlockImmediately: true, },
    { representation: "for"                  , name: "for"                            , isControlFlow: true, requiresParentheseBlockImmediately: true, },
    { representation: "do"                   , name: "do"                             , isControlFlow: true,                                           },
    { representation: "if"                   , name: "if"                             , isControlFlow: true, requiresParentheseBlockImmediately: true, },
    { representation: "else"                 , name: "else"                           , isControlFlow: true,                                           },
    { representation: "goto"                 , name: "goto"                           , isControlFlow: true,                                           },
    { representation: "switch"               , name: "switch"                         , isControlFlow: true, requiresParentheseBlockImmediately: true, },
    { representation: "try"                  , name: "try"                            , isControlFlow: true,                                           isExceptionRelated: true},
    { representation: "catch"                , name: "catch"                          , isControlFlow: true, requiresParentheseBlockImmediately: true, isExceptionRelated: true},
    { representation: "return"               , name: "return"                         , isControlFlow: true,                                           },
    { representation: "break"                , name: "break"                          , isControlFlow: true,                                           },
    { representation: "case"                 , name: "case"                           , isControlFlow: true,                                           },
    { representation: "continue"             , name: "continue"                       , isControlFlow: true,                                           },
    { representation: "default"              , name: "default"                        , isControlFlow: true,                                           },
    # primitive type keywords
    { representation: "auto"                 , name: "auto"                           , isPrimitive: true, isType: true},
    { representation: "void"                 , name: "void"                           , isPrimitive: true, isType: true},
    { representation: "char"                 , name: "char"                           , isPrimitive: true, isType: true},
    { representation: "short"                , name: "short"                          , isPrimitive: true, isType: true},
    { representation: "int"                  , name: "int"                            , isPrimitive: true, isType: true},
    { representation: "signed"               , name: "signed"                         , isPrimitive: true, isType: true},
    { representation: "unsigned"             , name: "unsigned"                       , isPrimitive: true, isType: true},
    { representation: "long"                 , name: "long"                           , isPrimitive: true, isType: true},
    { representation: "float"                , name: "float"                          , isPrimitive: true, isType: true},
    { representation: "double"               , name: "double"                         , isPrimitive: true, isType: true},
    { representation: "bool"                 , name: "bool"                           , isPrimitive: true, isType: true},
    { representation: "wchar_t"              , name: "wchar_t"                        , isPrimitive: true, isType: true},
    # other types
    { representation: "u_char"               , name: "u_char"               , isType: true },
    { representation: "u_short"              , name: "u_short"              , isType: true },
    { representation: "u_int"                , name: "u_int"                , isType: true },
    { representation: "u_long"               , name: "u_long"               , isType: true },
    { representation: "ushort"               , name: "ushort"               , isType: true },
    { representation: "uint"                 , name: "uint"                 , isType: true },
    { representation: "u_quad_t"             , name: "u_quad_t"             , isType: true },
    { representation: "quad_t"               , name: "quad_t"               , isType: true },
    { representation: "qaddr_t"              , name: "qaddr_t"              , isType: true },
    { representation: "caddr_t"              , name: "caddr_t"              , isType: true },
    { representation: "daddr_t"              , name: "daddr_t"              , isType: true },
    { representation: "div_t"                , name: "div_t"                , isType: true },
    { representation: "dev_t"                , name: "dev_t"                , isType: true },
    { representation: "fixpt_t"              , name: "fixpt_t"              , isType: true },
    { representation: "blkcnt_t"             , name: "blkcnt_t"             , isType: true },
    { representation: "blksize_t"            , name: "blksize_t"            , isType: true },
    { representation: "gid_t"                , name: "gid_t"                , isType: true },
    { representation: "in_addr_t"            , name: "in_addr_t"            , isType: true },
    { representation: "in_port_t"            , name: "in_port_t"            , isType: true },
    { representation: "ino_t"                , name: "ino_t"                , isType: true },
    { representation: "key_t"                , name: "key_t"                , isType: true },
    { representation: "mode_t"               , name: "mode_t"               , isType: true },
    { representation: "nlink_t"              , name: "nlink_t"              , isType: true },
    { representation: "id_t"                 , name: "id_t"                 , isType: true },
    { representation: "pid_t"                , name: "pid_t"                , isType: true },
    { representation: "off_t"                , name: "off_t"                , isType: true },
    { representation: "segsz_t"              , name: "segsz_t"              , isType: true },
    { representation: "swblk_t"              , name: "swblk_t"              , isType: true },
    { representation: "uid_t"                , name: "uid_t"                , isType: true },
    { representation: "id_t"                 , name: "id_t"                 , isType: true },
    { representation: "clock_t"              , name: "clock_t"              , isType: true },
    { representation: "size_t"               , name: "size_t"               , isType: true },
    { representation: "ssize_t"              , name: "ssize_t"              , isType: true },
    { representation: "time_t"               , name: "time_t"               , isType: true },
    { representation: "useconds_t"           , name: "useconds_t"           , isType: true },
    { representation: "suseconds_t"          , name: "suseconds_t"          , isType: true },
    { representation: "pthread_attr_t"       , name: "pthread_attr_t"       , isType: true },
    { representation: "pthread_cond_t"       , name: "pthread_cond_t"       , isType: true },
    { representation: "pthread_condattr_t"   , name: "pthread_condattr_t"   , isType: true },
    { representation: "pthread_mutex_t"      , name: "pthread_mutex_t"      , isType: true },
    { representation: "pthread_mutexattr_t"  , name: "pthread_mutexattr_t"  , isType: true },
    { representation: "pthread_once_t"       , name: "pthread_once_t"       , isType: true },
    { representation: "pthread_rwlock_t"     , name: "pthread_rwlock_t"     , isType: true },
    { representation: "pthread_rwlockattr_t" , name: "pthread_rwlockattr_t" , isType: true },
    { representation: "pthread_t"            , name: "pthread_t"            , isType: true },
    { representation: "pthread_key_t"        , name: "pthread_key_t"        , isType: true },
    { representation: "int8_t"               , name: "int8_t"               , isType: true },
    { representation: "int16_t"              , name: "int16_t"              , isType: true },
    { representation: "int32_t"              , name: "int32_t"              , isType: true },
    { representation: "int64_t"              , name: "int64_t"              , isType: true },
    { representation: "uint8_t"              , name: "uint8_t"              , isType: true },
    { representation: "uint16_t"             , name: "uint16_t"             , isType: true },
    { representation: "uint32_t"             , name: "uint32_t"             , isType: true },
    { representation: "uint64_t"             , name: "uint64_t"             , isType: true },
    { representation: "int_least8_t"         , name: "int_least8_t"         , isType: true },
    { representation: "int_least16_t"        , name: "int_least16_t"        , isType: true },
    { representation: "int_least32_t"        , name: "int_least32_t"        , isType: true },
    { representation: "int_least64_t"        , name: "int_least64_t"        , isType: true },
    { representation: "uint_least8_t"        , name: "uint_least8_t"        , isType: true },
    { representation: "uint_least16_t"       , name: "uint_least16_t"       , isType: true },
    { representation: "uint_least32_t"       , name: "uint_least32_t"       , isType: true },
    { representation: "uint_least64_t"       , name: "uint_least64_t"       , isType: true },
    { representation: "int_fast8_t"          , name: "int_fast8_t"          , isType: true },
    { representation: "int_fast16_t"         , name: "int_fast16_t"         , isType: true },
    { representation: "int_fast32_t"         , name: "int_fast32_t"         , isType: true },
    { representation: "int_fast64_t"         , name: "int_fast64_t"         , isType: true },
    { representation: "uint_fast8_t"         , name: "uint_fast8_t"         , isType: true },
    { representation: "uint_fast16_t"        , name: "uint_fast16_t"        , isType: true },
    { representation: "uint_fast32_t"        , name: "uint_fast32_t"        , isType: true },
    { representation: "uint_fast64_t"        , name: "uint_fast64_t"        , isType: true },
    { representation: "intptr_t"             , name: "intptr_t"             , isType: true },
    { representation: "uintptr_t"            , name: "uintptr_t"            , isType: true },
    { representation: "intmax_t"             , name: "intmax_t"             , isType: true },
    { representation: "intmax_t"             , name: "intmax_t"             , isType: true },
    { representation: "uintmax_t"            , name: "uintmax_t"            , isType: true },
    { representation: "uintmax_t"            , name: "uintmax_t"            , isType: true },
    # type modifiers
    { representation: "const"                , name: "const"            , isGenericTypeModifier: true },
    { representation: "static"               , name: "static"           , isGenericTypeModifier: true },
    { representation: "volatile"             , name: "volatile"         , isGenericTypeModifier: true },
    { representation: "register"             , name: "register"         , isGenericTypeModifier: true },
    { representation: "restrict"             , name: "restrict"         , isGenericTypeModifier: true },
    { representation: "constexpr"            , name: "constexpr"        , isLeftHandSideTypeModifier: true },
    { representation: "extern"               , name: "extern"           , isLeftHandSideTypeModifier: true },
    { representation: "inline"               , name: "inline"           , isLeftHandSideTypeModifier: true },
    { representation: "mutable"              , name: "mutable"          , isLeftHandSideTypeModifier: true },
    { representation: "friend"               , name: "friend"           , isLeftHandSideTypeModifier: true },
    # literals
    { representation: "NULL"                 , name: "NULL"             , isLiteral: true },
    { representation: "true"                 , name: "true"             , isLiteral: true },
    { representation: "false"                , name: "false"            , isLiteral: true },
    { representation: "nullptr"              , name: "nullptr"          , isLiteral: true },
    # type creators
    { representation: "class"                , name: "class"           , isTypeCreator: true},
    { representation: "struct"               , name: "struct"          , isTypeCreator: true},
    { representation: "union"                , name: "union"           , isTypeCreator: true},
    { representation: "enum"                 , name: "enum"            , isTypeCreator: true},
    # specifiers
    { representation: "explicit"             , name: "explicit"         , isSpecifier: true },
    { representation: "virtual"              , name: "virtual"          , isSpecifier: true },
    # lambda specifiers
    { representation: "mutable"                , name: "mutable"            , isLambdaSpecifier: true },
    { representation: "constexpr"              , name: "constexpr"          , isLambdaSpecifier: true },
    { representation: "consteval"              , name: "consteval"          , isLambdaSpecifier: true },
    # accessor
    { representation: "private"               , name: "private"             , isAccessSpecifier: true },
    { representation: "protected"             , name: "protected"           , isAccessSpecifier: true },
    { representation: "public"                , name: "public"              , isAccessSpecifier: true },
    # pre processor directives
    { representation: "if"                    , name: "if"                     , isPreprocessorDirective: true },
    { representation: "elif"                  , name: "elif"                   , isPreprocessorDirective: true },
    { representation: "else"                  , name: "else"                   , isPreprocessorDirective: true },
    { representation: "endif"                 , name: "endif"                  , isPreprocessorDirective: true },
    { representation: "ifdef"                 , name: "ifdef"                  , isPreprocessorDirective: true },
    { representation: "ifndef"                , name: "ifndef"                 , isPreprocessorDirective: true },
    { representation: "define"                , name: "define"                 , isPreprocessorDirective: true },
    { representation: "undef"                 , name: "undef"                  , isPreprocessorDirective: true },
    { representation: "include"               , name: "include"                , isPreprocessorDirective: true },
    { representation: "line"                  , name: "line"                   , isPreprocessorDirective: true },
    { representation: "error"                 , name: "error"                  , isPreprocessorDirective: true },
    { representation: "warning"               , name: "warning"                , isPreprocessorDirective: true },
    { representation: "pragma"                , name: "pragma"                 , isPreprocessorDirective: true },
    { representation: "_Pragma"               , name: "pragma"                 , isPreprocessorDirective: true },
    { representation: "defined"               , name: "defined"                , isPreprocessorDirective: true },
    { representation: "__has_include"         , name: "__has_include"          , isPreprocessorDirective: true },
    { representation: "__has_cpp_attribute"   , name: "__has_cpp_attribute"    , isPreprocessorDirective: true },
    # 
    # misc
    # 
    { representation: "this"            , name: "this"          },
    { representation: "template"        , name: "template"      },
    { representation: "namespace"       , name: "namespace"     },
    { representation: "using"           , name: "using"         },
    { representation: "operator"        , name: "operator"      },
    # 
    { representation: "typedef"         , name: "typedef"       },
    { representation: "decltype"        , name: "decltype"      },
    { representation: "typename"        , name: "typename"      },
    # 
    { representation: "asm"                        , name: "asm"                        },
    { representation: "__asm__"                    , name: "__asm__"                    },
    # 
    { representation: "atomic_cancel"              , name: "atomic_cancel"              },
    { representation: "atomic_commit"              , name: "atomic_commit"              },
    { representation: "atomic_noexcept"            , name: "atomic_noexcept"            },
    { representation: "concept"                    , name: "concept"                    },
    { representation: "co_await"                   , name: "co_await"                   },
    { representation: "co_return"                  , name: "co_return"                  },
    { representation: "co_yield"                   , name: "co_yield"                   },
    { representation: "export"                     , name: "export"                     },
    { representation: "import"                     , name: "import"                     },
    { representation: "module"                     , name: "module"                     },
    { representation: "reflexpr"                   , name: "reflexpr"                   },
    { representation: "requires"                   , name: "requires"                   },
    { representation: "synchronized"               , name: "synchronized"               },
    { representation: "thread_local"               , name: "thread_local"               },
    # 
    { representation: "audit"                      , name: "audit"                      },
    { representation: "axiom"                      , name: "axiom"                      },
    { representation: "transaction_safe"           , name: "transaction_safe"           },
    { representation: "transaction_safe_dynamic"   , name: "transaction_safe_dynamic"   },
]



@cpp_tokens = TokenHelper.new tokens, for_each_token: ->(each) do 
    # isSymbol, isWordish
    if each[:representation] =~ /[a-zA-Z0-9_]/
        each[:isWordish] = true
    else
        each[:isSymbol] = true
    end
    # isWord
    if each[:representation] =~ /\A[a-zA-Z_][a-zA-Z0-9_]*\z/
        each[:isWord] = true
    end
end
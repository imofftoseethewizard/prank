const fs = require("fs");

const wasmModule = new WebAssembly.Module(fs.readFileSync("lex.wasm"));
const wasmInstance = new WebAssembly.Instance(wasmModule, {});

const { memory } = wasmInstance.exports;

const ascii_lower                                     = wasmInstance.exports['ascii-lower'];
const char_eq_ascii_ci                                = wasmInstance.exports['char-eq/ascii-ci'];
const lex_match_empty                                 = wasmInstance.exports['lex-match-empty'];
const lex_match_any_char                              = wasmInstance.exports['lex-match-any-char'];
const lex_match_char_ascii                            = wasmInstance.exports['lex-match-char/ascii'];
const lex_match_char_ascii_ci                         = wasmInstance.exports['lex-match-char/ascii-ci'];
const lex_match_char_complement_ascii_set_of_2        = wasmInstance.exports['lex-match-char-complement/ascii/set-of-2'];
const lex_match_char_range_ascii                      = wasmInstance.exports['lex-match-char-range/ascii'];
const match_charset                                   = wasmInstance.exports['match-charset'];
const lex_match_charset                               = wasmInstance.exports['lex-match-charset'];
const match_static_string                             = wasmInstance.exports['match-static-string'];
const lex_match_static_string                         = wasmInstance.exports['lex-match-static-string'];
const match_static_string_ascii_ci                    = wasmInstance.exports['match-static-string/ascii-ci'];
const lex_match_static_string_ascii_ci                = wasmInstance.exports['lex-match-static-string/ascii-ci'];
const lex_match_static_strings_longest_of_2           = wasmInstance.exports['lex-match-static-strings/longest-of-2'];
const lex_match_static_strings_ascii_ci_longest_of_2  = wasmInstance.exports['lex-match-static-strings/ascii-ci/longest-of-2'];
const lex_match_static_strings_longest_of_3           = wasmInstance.exports['lex-match-static-strings/longest-of-3'];
const lex_match_static_strings_ascii_ci_longest_of_3  = wasmInstance.exports['lex-match-static-strings/ascii-ci/longest-of-3'];
const lex_match_static_strings_longest_of_4           = wasmInstance.exports['lex-match-static-strings/longest-of-4'];
const lex_does_rule_match                             = wasmInstance.exports['lex-match-rule?'];
const lex_match_rule_zero_or_more                     = wasmInstance.exports['lex-match-rule/zero-or-more'];
const lex_match_rule_one_or_more                      = wasmInstance.exports['lex-match-rule/one-or-more'];
const lex_match_rules_sequence                        = wasmInstance.exports['lex-match-rules/sequence'];
const lex_match_rules_sequence_of_2                   = wasmInstance.exports['lex-match-rules/sequence-of-2'];
const lex_match_rules_sequence_of_3                   = wasmInstance.exports['lex-match-rules/sequence-of-3'];
const lex_match_rules_sequence_of_4                   = wasmInstance.exports['lex-match-rules/sequence-of-4'];
const lex_match_rules_longest                         = wasmInstance.exports['lex-match-rules/longest'];
const lex_match_rules_longest_of_2                    = wasmInstance.exports['lex-match-rules/longest-of-2'];
const lex_match_rules_longest_of_3                    = wasmInstance.exports['lex-match-rules/longest-of-3'];
const lex_match_rules_longest_of_4                    = wasmInstance.exports['lex-match-rules/longest-of-4'];
const lex_match_rules_longest_unordered_sequence_of_2 = wasmInstance.exports['lex-match-rules/longest-unordered-sequence-of-2'];
const lex_match_until_rule                            = wasmInstance.exports['lex-match-until-rule'];
const lex_token_relabel                               = wasmInstance.exports['lex-token-relabel'];
const lex_match_token                                 = wasmInstance.exports['lex-match-token'];
const lex_rule_token                                  = wasmInstance.exports['lex-rule-token'];
const lex_match_token_group_1                         = wasmInstance.exports['lex-match-token/group-1'];
const lex_rule_token_group_1                          = wasmInstance.exports['lex-rule-token/group-1'];
const lex_match_token_group_2                         = wasmInstance.exports['lex-match-token/group-2'];
const lex_rule_token_group_2                          = wasmInstance.exports['lex-rule-token/group-2'];
const lex_match_token_char                            = wasmInstance.exports['lex-match-token-char'];
const lex_rule_token_char                             = wasmInstance.exports['lex-rule-token-char'];
const static_string_token_charset                     = wasmInstance.exports['static-string-token-charset'];
const lex_match_token_string                          = wasmInstance.exports['lex-match-token-string'];
const lex_rule_token_string                           = wasmInstance.exports['lex-rule-token-string'];
const static_string_begin_syntax                      = wasmInstance.exports['static-string-begin-syntax'];
const static_string_begin_bytevector                  = wasmInstance.exports['static-string-begin-bytevector'];
const static_string_unquote_splicing                  = wasmInstance.exports['static-string-unquote-splicing'];
const lex_match_delimiter                             = wasmInstance.exports['lex-match-delimiter'];
const lex_rule_delimiter                              = wasmInstance.exports['lex-rule-delimiter'];
const lex_match_delimiter_char                        = wasmInstance.exports['lex-match-delimiter-char'];
const lex_rule_delimiter_char                         = wasmInstance.exports['lex-rule-delimiter-char'];
const static_string_delimiter_charset                 = wasmInstance.exports['static-string-delimiter-charset'];
const lex_match_intraline_whitespace                  = wasmInstance.exports['lex-match-intraline-whitespace'];
const lex_rule_intraline_whitespace                   = wasmInstance.exports['lex-rule-intraline-whitespace'];
const static_string_intraline_whitespace              = wasmInstance.exports['static-string-intraline-whitespace'];
const lex_match_whitespace                            = wasmInstance.exports['lex-match-whitespace'];
const lex_rule_whitespace                             = wasmInstance.exports['lex-rule-whitespace'];
const lex_match_vertical_line                         = wasmInstance.exports['lex-match-vertical-line'];
const lex_rule_vertical_line                          = wasmInstance.exports['lex-rule-vertical-line'];
const lex_match_line_ending                           = wasmInstance.exports['lex-match-line-ending'];
const lex_rule_line_ending                            = wasmInstance.exports['lex-rule-line-ending'];
const lex_match_line_ending_char                      = wasmInstance.exports['lex-match-line-ending-char'];
const lex_rule_line_ending_char                       = wasmInstance.exports['lex-rule-line-ending-char'];
const static_string_line_ending_charset               = wasmInstance.exports['static-string-line-ending-charset'];
const lex_match_dos_line_ending                       = wasmInstance.exports['lex-match-dos-line-ending'];
const lex_rule_dos_line_ending                        = wasmInstance.exports['lex-rule-dos-line-ending'];
const static_string_dos_line_ending                   = wasmInstance.exports['static-string-dos-line-ending'];
const lex_match_comment                               = wasmInstance.exports['lex-match-comment'];
const lex_rule_comment                                = wasmInstance.exports['lex-rule-comment'];
const lex_match_simple_comment                        = wasmInstance.exports['lex-match-simple-comment'];
const lex_rule_simple_comment                         = wasmInstance.exports['lex-rule-simple-comment'];
const lex_match_semicolon                             = wasmInstance.exports['lex-match-semicolon'];
const lex_rule_semicolon                              = wasmInstance.exports['lex-rule-semicolon'];
const lex_match_simple_comment_continuation           = wasmInstance.exports['lex-match-simple-comment-continuation'];
const lex_rule_simple_comment_continuation            = wasmInstance.exports['lex-rule-simple-comment-continuation'];
const lex_match_datum_comment                         = wasmInstance.exports['lex-match-datum-comment'];
const lex_rule_datum_comment                          = wasmInstance.exports['lex-rule-datum-comment'];
const lex_match_begin_datum_comment                   = wasmInstance.exports['lex-match-begin-datum-comment'];
const lex_rule_begin_datum_comment                    = wasmInstance.exports['lex-rule-begin-datum-comment'];
const static_string_begin_datum_comment               = wasmInstance.exports['static-string-begin-datum-comment'];
const lex_match_nested_comment                        = wasmInstance.exports['lex-match-nested-comment'];
const lex_rule_nested_comment                         = wasmInstance.exports['lex-rule-nested-comment'];
const lex_match_begin_nested_comment                  = wasmInstance.exports['lex-match-begin-nested-comment'];
const lex_rule_begin_nested_comment                   = wasmInstance.exports['lex-rule-begin-nested-comment'];
const static_string_begin_nested_comment              = wasmInstance.exports['static-string-begin-nested-comment'];
const lex_match_comment_continuations                 = wasmInstance.exports['lex-match-comment-continuations'];
const lex_rule_comment_continuations                  = wasmInstance.exports['lex-rule-comment-continuations'];
const lex_match_end_nested_comment                    = wasmInstance.exports['lex-match-end-nested-comment'];
const lex_rule_end_nested_comment                     = wasmInstance.exports['lex-rule-end-nested-comment'];
const static_string_end_nested_comment                = wasmInstance.exports['static-string-end-nested-comment'];
const lex_match_comment_text                          = wasmInstance.exports['lex-match-comment-text'];
const lex_rule_comment_text                           = wasmInstance.exports['lex-rule-comment-text'];
const lex_match_nested_comment_delimiters             = wasmInstance.exports['lex-match-nested-comment-delimiters'];
const lex_rule_nested_comment_delimiters              = wasmInstance.exports['lex-rule-nested-comment-delimiters'];
const lex_match_comment_continuation                  = wasmInstance.exports['lex-match-comment-continuation'];
const lex_rule_comment_continuation                   = wasmInstance.exports['lex-rule-comment-continuation'];
const lex_match_directive                             = wasmInstance.exports['lex-match-directive'];
const lex_rule_directive                              = wasmInstance.exports['lex-rule-directive'];
const static_string_directive_fold_case               = wasmInstance.exports['static-string-directive-fold-case'];
const static_string_directive_no_fold_case            = wasmInstance.exports['static-string-directive-no-fold-case'];
const lex_match_atmosphere                            = wasmInstance.exports['lex-match-atmosphere'];
const lex_rule_atmosphere                             = wasmInstance.exports['lex-rule-atmosphere'];
const lex_match_intertoken_space                      = wasmInstance.exports['lex-match-intertoken-space'];
const lex_rule_intertoken_space                       = wasmInstance.exports['lex-rule-intertoken-space'];
const lex_match_identifier                            = wasmInstance.exports['lex-match-identifier'];
const lex_rule_identifier                             = wasmInstance.exports['lex-rule-identifier'];
const lex_match_ordinary_identifier                   = wasmInstance.exports['lex-match-ordinary-identifier'];
const lex_rule_ordinary_identifier                    = wasmInstance.exports['lex-rule-ordinary-identifier'];
const lex_match_subsequents                           = wasmInstance.exports['lex-match-subsequents'];
const lex_rule_subsequents                            = wasmInstance.exports['lex-rule-subsequents'];
const lex_match_symbol                                = wasmInstance.exports['lex-match-symbol'];
const lex_rule_symbol                                 = wasmInstance.exports['lex-rule-symbol'];
const lex_match_symbol_elements                       = wasmInstance.exports['lex-match-symbol-elements'];
const lex_rule_symbol_elements                        = wasmInstance.exports['lex-rule-symbol-elements'];
const lex_match_initial                               = wasmInstance.exports['lex-match-initial'];
const lex_rule_initial                                = wasmInstance.exports['lex-rule-initial'];
const lex_match_letter                                = wasmInstance.exports['lex-match-letter'];
const lex_rule_letter                                 = wasmInstance.exports['lex-rule-letter'];
const lex_match_lowercase_letter                      = wasmInstance.exports['lex-match-lowercase-letter'];
const lex_rule_lowercase_letter                       = wasmInstance.exports['lex-rule-lowercase-letter'];
const lex_match_uppercase_letter                      = wasmInstance.exports['lex-match-uppercase-letter'];
const lex_rule_uppercase_letter                       = wasmInstance.exports['lex-rule-uppercase-letter'];
const lex_match_special_initial                       = wasmInstance.exports['lex-match-special-initial'];
const lex_rule_special_initial                        = wasmInstance.exports['lex-rule-special-initial'];
const static_string_special_initials                  = wasmInstance.exports['static-string-special-initials'];
const lex_match_subsequent                            = wasmInstance.exports['lex-match-subsequent'];
const lex_rule_subsequent                             = wasmInstance.exports['lex-rule-subsequent'];
const lex_match_digit                                 = wasmInstance.exports['lex-match-digit'];
const lex_rule_digit                                  = wasmInstance.exports['lex-rule-digit'];
const lex_match_hex_digit                             = wasmInstance.exports['lex-match-hex-digit'];
const lex_rule_hex_digit                              = wasmInstance.exports['lex-rule-hex-digit'];
const lex_match_hex_digit_alphabetic                  = wasmInstance.exports['lex-match-hex-digit/alphabetic'];
const lex_rule_hex_digit_alphabetic                   = wasmInstance.exports['lex-rule-hex-digit/alphabetic'];
const lex_match_explicit_sign                         = wasmInstance.exports['lex-match-explicit-sign'];
const lex_rule_explicit_sign                          = wasmInstance.exports['lex-rule-explicit-sign'];
const static_string_explicit_sign_charset             = wasmInstance.exports['static-string-explicit-sign-charset'];
const lex_match_special_subsequent                    = wasmInstance.exports['lex-match-special-subsequent'];
const lex_rule_special_subsequent                     = wasmInstance.exports['lex-rule-special-subsequent'];
const lex_match_special_subsequent_dot_or_at          = wasmInstance.exports['lex-match-special-subsequent/dot-or-at'];
const lex_rule_special_subsequent_dot_or_at           = wasmInstance.exports['lex-rule-special-subsequent/dot-or-at'];
const static_string_dot_and_at                        = wasmInstance.exports['static-string-dot-and-at'];
const lex_match_inline_hex_escape                     = wasmInstance.exports['lex-match-inline-hex-escape'];
const lex_rule_inline_hex_escape                      = wasmInstance.exports['lex-rule-inline-hex-escape'];
const lex_match_inline_hex_escape_prefix              = wasmInstance.exports['lex-match-inline-hex-escape-prefix'];
const lex_rule_inline_hex_escape_prefix               = wasmInstance.exports['lex-rule-inline-hex-escape-prefix'];
const static_string_inline_escape_prefix              = wasmInstance.exports['static-string-inline-escape-prefix'];
const lex_match_hex_scalar_value                      = wasmInstance.exports['lex-match-hex-scalar-value'];
const lex_rule_hex_scalar_value                       = wasmInstance.exports['lex-rule-hex-scalar-value'];
const lex_match_mnemonic_escape                       = wasmInstance.exports['lex-match-mnemonic-escape'];
const lex_rule_mnemonic_escape                        = wasmInstance.exports['lex-rule-mnemonic-escape'];
const lex_match_backslash                             = wasmInstance.exports['lex-match-backslash'];
const lex_rule_backslash                              = wasmInstance.exports['lex-rule-backslash'];
const lex_match_mnemonic_escape_character             = wasmInstance.exports['lex-match-mnemonic-escape-character'];
const lex_rule_mnemonic_escape_character              = wasmInstance.exports['lex-rule-mnemonic-escape-character'];
const static_string_mnemonic_escapes                  = wasmInstance.exports['static-string-mnemonic-escapes'];
const lex_match_peculiar_identifier                   = wasmInstance.exports['lex-match-peculiar-identifier'];
const lex_rule_peculiar_identifier                    = wasmInstance.exports['lex-rule-peculiar-identifier'];
const lex_match_peculiar_identifier_form_1            = wasmInstance.exports['lex-match-peculiar-identifier/form-1'];
const lex_rule_peculiar_identifier_form_1             = wasmInstance.exports['lex-rule-peculiar-identifier/form-1'];
const lex_match_peculiar_identifier_form_2            = wasmInstance.exports['lex-match-peculiar-identifier/form-2'];
const lex_rule_peculiar_identifier_form_2             = wasmInstance.exports['lex-rule-peculiar-identifier/form-2'];
const lex_match_dot                                   = wasmInstance.exports['lex-match-dot'];
const lex_rule_dot                                    = wasmInstance.exports['lex-rule-dot'];
const lex_match_peculiar_identifier_form_3            = wasmInstance.exports['lex-match-peculiar-identifier/form-3'];
const lex_rule_peculiar_identifier_form_3             = wasmInstance.exports['lex-rule-peculiar-identifier/form-3'];
const lex_match_dot_subsequent                        = wasmInstance.exports['lex-match-dot-subsequent'];
const lex_rule_dot_subsequent                         = wasmInstance.exports['lex-rule-dot-subsequent'];
const lex_match_sign_subsequent                       = wasmInstance.exports['lex-match-sign-subsequent'];
const lex_rule_sign_subsequent                        = wasmInstance.exports['lex-rule-sign-subsequent'];
const lex_match_at_sign                               = wasmInstance.exports['lex-match-at-sign'];
const lex_rule_at_sign                                = wasmInstance.exports['lex-rule-at-sign'];
const lex_match_symbol_element                        = wasmInstance.exports['lex-match-symbol-element'];
const lex_rule_symbol_element                         = wasmInstance.exports['lex-rule-symbol-element'];
const lex_match_symbol_element_character              = wasmInstance.exports['lex-match-symbol-element/character'];
const lex_rule_symbol_element_character               = wasmInstance.exports['lex-rule-symbol-element/character'];
const lex_match_escaped_vertical_line                 = wasmInstance.exports['lex-match-escaped-vertical-line'];
const lex_rule_escaped_vertical_line                  = wasmInstance.exports['lex-rule-escaped-vertical-line'];
const lex_match_boolean                               = wasmInstance.exports['lex-match-boolean'];
const lex_rule_boolean                                = wasmInstance.exports['lex-rule-boolean'];
const static_string_boolean_t                         = wasmInstance.exports['static-string-boolean-t'];
const static_string_boolean_f                         = wasmInstance.exports['static-string-boolean-f'];
const static_string_boolean_true                      = wasmInstance.exports['static-string-boolean-true'];
const static_string_boolean_false                     = wasmInstance.exports['static-string-boolean-false'];
const lex_match_character                             = wasmInstance.exports['lex-match-character'];
const lex_rule_character                              = wasmInstance.exports['lex-rule-character'];
const lex_match_escaped_character                     = wasmInstance.exports['lex-match-escaped-character'];
const lex_rule_escaped_character                      = wasmInstance.exports['lex-rule-escaped-character'];
const lex_rule_any_char                               = wasmInstance.exports['lex-rule-any-char'];
const lex_match_character_prefix                      = wasmInstance.exports['lex-match-character-prefix'];
const lex_rule_character_prefix                       = wasmInstance.exports['lex-rule-character-prefix'];
const static_string_character_prefix                  = wasmInstance.exports['static-string-character-prefix'];
const lex_match_named_character                       = wasmInstance.exports['lex-match-named-character'];
const lex_rule_named_character                        = wasmInstance.exports['lex-rule-named-character'];
const lex_match_escaped_character_hex                 = wasmInstance.exports['lex-match-escaped-character-hex'];
const lex_rule_escaped_character_hex                  = wasmInstance.exports['lex-rule-escaped-character-hex'];
const lex_match_character_hex_prefix                  = wasmInstance.exports['lex-match-character-hex-prefix'];
const lex_rule_character_hex_prefix                   = wasmInstance.exports['lex-rule-character-hex-prefix'];
const static_string_character_hex_prefix              = wasmInstance.exports['static-string-character-hex-prefix'];
const lex_match_character_name                        = wasmInstance.exports['lex-match-character-name'];
const lex_rule_character_name                         = wasmInstance.exports['lex-rule-character-name'];
const lex_match_character_name_group_1                = wasmInstance.exports['lex-match-character-name/group-1'];
const lex_rule_character_name_group_1                 = wasmInstance.exports['lex-rule-character-name/group-1'];
const lex_match_character_name_group_2                = wasmInstance.exports['lex-match-character-name/group-2'];
const lex_rule_character_name_group_2                 = wasmInstance.exports['lex-rule-character-name/group-2'];
const lex_match_character_name_group_3                = wasmInstance.exports['lex-match-character-name/group-3'];
const lex_rule_character_name_group_3                 = wasmInstance.exports['lex-rule-character-name/group-3'];
const static_string_alarm                             = wasmInstance.exports['static-string-alarm'];
const static_string_backspace                         = wasmInstance.exports['static-string-backspace'];
const static_string_delete                            = wasmInstance.exports['static-string-delete'];
const static_string_escape                            = wasmInstance.exports['static-string-escape'];
const static_string_newline                           = wasmInstance.exports['static-string-newline'];
const static_string_null                              = wasmInstance.exports['static-string-null'];
const static_string_return                            = wasmInstance.exports['static-string-return'];
const static_string_space                             = wasmInstance.exports['static-string-space'];
const static_string_tab                               = wasmInstance.exports['static-string-tab'];
const lex_match_string                                = wasmInstance.exports['lex-match-string'];
const lex_rule_string                                 = wasmInstance.exports['lex-rule-string'];
const lex_match_double_quote                          = wasmInstance.exports['lex-match-double-quote'];
const lex_rule_double_quote                           = wasmInstance.exports['lex-rule-double-quote'];
const lex_match_string_elements                       = wasmInstance.exports['lex-match-string-elements'];
const lex_rule_string_elements                        = wasmInstance.exports['lex-rule-string-elements'];
const lex_match_string_element                        = wasmInstance.exports['lex-match-string-element'];
const lex_rule_string_element                         = wasmInstance.exports['lex-rule-string-element'];
const lex_match_string_element_character              = wasmInstance.exports['lex-match-string-element/character'];
const lex_rule_string_element_character               = wasmInstance.exports['lex-rule-string-element/character'];
const lex_match_string_element_character_escape       = wasmInstance.exports['lex-match-string-element/character-escape'];
const lex_rule_string_element_character_escape        = wasmInstance.exports['lex-rule-string-element/character-escape'];
const lex_match_escaped_double_quote                  = wasmInstance.exports['lex-match-escaped-double-quote'];
const lex_rule_escaped_double_quote                   = wasmInstance.exports['lex-rule-escaped-double-quote'];
const lex_match_escaped_backslash                     = wasmInstance.exports['lex-match-escaped-backslash'];
const lex_rule_escaped_backslash                      = wasmInstance.exports['lex-rule-escaped-backslash'];
const lex_match_escaped_line_ending                   = wasmInstance.exports['lex-match-escaped-line-ending'];
const lex_rule_escaped_line_ending                    = wasmInstance.exports['lex-rule-escaped-line-ending'];
const lex_match_some_intraline_whitespace             = wasmInstance.exports['lex-match-some-intraline-whitespace'];
const lex_rule_some_intraline_whitespace              = wasmInstance.exports['lex-rule-some-intraline-whitespace'];
const lex_match_number                                = wasmInstance.exports['lex-match-number'];
const lex_rule_number                                 = wasmInstance.exports['lex-rule-number'];
const lex_match_num_2                                 = wasmInstance.exports['lex-match-num-2'];
const lex_rule_num_2                                  = wasmInstance.exports['lex-rule-num-2'];
const lex_match_num_8                                 = wasmInstance.exports['lex-match-num-8'];
const lex_rule_num_8                                  = wasmInstance.exports['lex-rule-num-8'];
const lex_match_num_10                                = wasmInstance.exports['lex-match-num-10'];
const lex_rule_num_10                                 = wasmInstance.exports['lex-rule-num-10'];
const lex_match_num_16                                = wasmInstance.exports['lex-match-num-16'];
const lex_rule_num_16                                 = wasmInstance.exports['lex-rule-num-16'];
const lex_match_complex_16                            = wasmInstance.exports['lex-match-complex-16'];
const lex_rule_complex_16                             = wasmInstance.exports['lex-rule-complex-16'];
const lex_match_complex_10                            = wasmInstance.exports['lex-match-complex-10'];
const lex_rule_complex_10                             = wasmInstance.exports['lex-rule-complex-10'];
const lex_match_complex_8                             = wasmInstance.exports['lex-match-complex-8'];
const lex_rule_complex_8                              = wasmInstance.exports['lex-rule-complex-8'];
const lex_match_complex_2                             = wasmInstance.exports['lex-match-complex-2'];
const lex_rule_complex_2                              = wasmInstance.exports['lex-rule-complex-2'];
const lex_match_simple_im                             = wasmInstance.exports['lex-match-simple-im'];
const lex_rule_simple_im                              = wasmInstance.exports['lex-rule-simple-im'];
const lex_match_unit_im                               = wasmInstance.exports['lex-match-unit-im'];
const lex_rule_unit_im                                = wasmInstance.exports['lex-rule-unit-im'];
const lex_match_complex_i                             = wasmInstance.exports['lex-match-complex-i'];
const lex_rule_complex_i                              = wasmInstance.exports['lex-rule-complex-i'];
const lex_match_infnan_im                             = wasmInstance.exports['lex-match-infnan-im'];
const lex_rule_infnan_im                              = wasmInstance.exports['lex-rule-infnan-im'];
const lex_match_complex_16_group_1                    = wasmInstance.exports['lex-match-complex-16/group-1'];
const lex_rule_complex_16_group_1                     = wasmInstance.exports['lex-rule-complex-16/group-1'];
const lex_match_complex_10_group_1                    = wasmInstance.exports['lex-match-complex-10/group-1'];
const lex_rule_complex_10_group_1                     = wasmInstance.exports['lex-rule-complex-10/group-1'];
const lex_match_complex_8_group_1                     = wasmInstance.exports['lex-match-complex-8/group-1'];
const lex_rule_complex_8_group_1                      = wasmInstance.exports['lex-rule-complex-8/group-1'];
const lex_match_complex_2_group_1                     = wasmInstance.exports['lex-match-complex-2/group-1'];
const lex_rule_complex_2_group_1                      = wasmInstance.exports['lex-rule-complex-2/group-1'];
const lex_match_complex_polar_16                      = wasmInstance.exports['lex-match-complex-polar-16'];
const lex_rule_complex_polar_16                       = wasmInstance.exports['lex-rule-complex-polar-16'];
const lex_match_complex_polar_10                      = wasmInstance.exports['lex-match-complex-polar-10'];
const lex_rule_complex_polar_10                       = wasmInstance.exports['lex-rule-complex-polar-10'];
const lex_match_complex_polar_8                       = wasmInstance.exports['lex-match-complex-polar-8'];
const lex_rule_complex_polar_8                        = wasmInstance.exports['lex-rule-complex-polar-8'];
const lex_match_complex_polar_2                       = wasmInstance.exports['lex-match-complex-polar-2'];
const lex_rule_complex_polar_2                        = wasmInstance.exports['lex-rule-complex-polar-2'];
const lex_match_complex_infnan_im_16                  = wasmInstance.exports['lex-match-complex-infnan-im-16'];
const lex_rule_complex_infnan_im_16                   = wasmInstance.exports['lex-rule-complex-infnan-im-16'];
const lex_match_complex_infnan_im_10                  = wasmInstance.exports['lex-match-complex-infnan-im-10'];
const lex_rule_complex_infnan_im_10                   = wasmInstance.exports['lex-rule-complex-infnan-im-10'];
const lex_match_complex_infnan_im_8                   = wasmInstance.exports['lex-match-complex-infnan-im-8'];
const lex_rule_complex_infnan_im_8                    = wasmInstance.exports['lex-rule-complex-infnan-im-8'];
const lex_match_complex_infnan_im_2                   = wasmInstance.exports['lex-match-complex-infnan-im-2'];
const lex_rule_complex_infnan_im_2                    = wasmInstance.exports['lex-rule-complex-infnan-im-2'];
const lex_match_complex_16_group_2                    = wasmInstance.exports['lex-match-complex-16/group-2'];
const lex_rule_complex_16_group_2                     = wasmInstance.exports['lex-rule-complex-16/group-2'];
const lex_match_complex_10_group_2                    = wasmInstance.exports['lex-match-complex-10/group-2'];
const lex_rule_complex_10_group_2                     = wasmInstance.exports['lex-rule-complex-10/group-2'];
const lex_match_complex_8_group_2                     = wasmInstance.exports['lex-match-complex-8/group-2'];
const lex_rule_complex_8_group_2                      = wasmInstance.exports['lex-rule-complex-8/group-2'];
const lex_match_complex_2_group_2                     = wasmInstance.exports['lex-match-complex-2/group-2'];
const lex_rule_complex_2_group_2                      = wasmInstance.exports['lex-rule-complex-2/group-2'];
const lex_match_full_complex_16                       = wasmInstance.exports['lex-match-full-complex-16'];
const lex_rule_full_complex_16                        = wasmInstance.exports['lex-rule-full-complex-16'];
const lex_match_full_complex_10                       = wasmInstance.exports['lex-match-full-complex-10'];
const lex_rule_full_complex_10                        = wasmInstance.exports['lex-rule-full-complex-10'];
const lex_match_full_complex_8                        = wasmInstance.exports['lex-match-full-complex-8'];
const lex_rule_full_complex_8                         = wasmInstance.exports['lex-rule-full-complex-8'];
const lex_match_full_complex_2                        = wasmInstance.exports['lex-match-full-complex-2'];
const lex_rule_full_complex_2                         = wasmInstance.exports['lex-rule-full-complex-2'];
const lex_match_complex_unit_im_16                    = wasmInstance.exports['lex-match-complex-unit-im-16'];
const lex_rule_complex_unit_im_16                     = wasmInstance.exports['lex-rule-complex-unit-im-16'];
const lex_match_complex_unit_im_10                    = wasmInstance.exports['lex-match-complex-unit-im-10'];
const lex_rule_complex_unit_im_10                     = wasmInstance.exports['lex-rule-complex-unit-im-10'];
const lex_match_complex_unit_im_8                     = wasmInstance.exports['lex-match-complex-unit-im-8'];
const lex_rule_complex_unit_im_8                      = wasmInstance.exports['lex-rule-complex-unit-im-8'];
const lex_match_complex_unit_im_2                     = wasmInstance.exports['lex-match-complex-unit-im-2'];
const lex_rule_complex_unit_im_2                      = wasmInstance.exports['lex-rule-complex-unit-im-2'];
const lex_match_complex_im_only_16                    = wasmInstance.exports['lex-match-complex-im-only-16'];
const lex_rule_complex_im_only_16                     = wasmInstance.exports['lex-rule-complex-im-only-16'];
const lex_match_complex_im_only_10                    = wasmInstance.exports['lex-match-complex-im-only-10'];
const lex_rule_complex_im_only_10                     = wasmInstance.exports['lex-rule-complex-im-only-10'];
const lex_match_complex_im_only_8                     = wasmInstance.exports['lex-match-complex-im-only-8'];
const lex_rule_complex_im_only_8                      = wasmInstance.exports['lex-rule-complex-im-only-8'];
const lex_match_complex_im_only_2                     = wasmInstance.exports['lex-match-complex-im-only-2'];
const lex_rule_complex_im_only_2                      = wasmInstance.exports['lex-rule-complex-im-only-2'];
const lex_match_real_16                               = wasmInstance.exports['lex-match-real-16'];
const lex_rule_real_16                                = wasmInstance.exports['lex-rule-real-16'];
const lex_match_real_10                               = wasmInstance.exports['lex-match-real-10'];
const lex_rule_real_10                                = wasmInstance.exports['lex-rule-real-10'];
const lex_match_real_8                                = wasmInstance.exports['lex-match-real-8'];
const lex_rule_real_8                                 = wasmInstance.exports['lex-rule-real-8'];
const lex_match_real_2                                = wasmInstance.exports['lex-match-real-2'];
const lex_rule_real_2                                 = wasmInstance.exports['lex-rule-real-2'];
const lex_match_signed_real_16                        = wasmInstance.exports['lex-match-signed-real-16'];
const lex_rule_signed_real_16                         = wasmInstance.exports['lex-rule-signed-real-16'];
const lex_match_signed_real_10                        = wasmInstance.exports['lex-match-signed-real-10'];
const lex_rule_signed_real_10                         = wasmInstance.exports['lex-rule-signed-real-10'];
const lex_match_signed_real_8                         = wasmInstance.exports['lex-match-signed-real-8'];
const lex_rule_signed_real_8                          = wasmInstance.exports['lex-rule-signed-real-8'];
const lex_match_signed_real_2                         = wasmInstance.exports['lex-match-signed-real-2'];
const lex_rule_signed_real_2                          = wasmInstance.exports['lex-rule-signed-real-2'];
const lex_match_ureal_16                              = wasmInstance.exports['lex-match-ureal-16'];
const lex_rule_ureal_16                               = wasmInstance.exports['lex-rule-ureal-16'];
const lex_match_ureal_10                              = wasmInstance.exports['lex-match-ureal-10'];
const lex_rule_ureal_10                               = wasmInstance.exports['lex-rule-ureal-10'];
const lex_match_ureal_8                               = wasmInstance.exports['lex-match-ureal-8'];
const lex_rule_ureal_8                                = wasmInstance.exports['lex-rule-ureal-8'];
const lex_match_ureal_2                               = wasmInstance.exports['lex-match-ureal-2'];
const lex_rule_ureal_2                                = wasmInstance.exports['lex-rule-ureal-2'];
const lex_match_urational_16                          = wasmInstance.exports['lex-match-urational-16'];
const lex_rule_urational_16                           = wasmInstance.exports['lex-rule-urational-16'];
const lex_match_urational_10                          = wasmInstance.exports['lex-match-urational-10'];
const lex_rule_urational_10                           = wasmInstance.exports['lex-rule-urational-10'];
const lex_match_urational_8                           = wasmInstance.exports['lex-match-urational-8'];
const lex_rule_urational_8                            = wasmInstance.exports['lex-rule-urational-8'];
const lex_match_urational_2                           = wasmInstance.exports['lex-match-urational-2'];
const lex_rule_urational_2                            = wasmInstance.exports['lex-rule-urational-2'];
const lex_match_slash                                 = wasmInstance.exports['lex-match-slash'];
const lex_rule_slash                                  = wasmInstance.exports['lex-rule-slash'];
const lex_match_decimal_10                            = wasmInstance.exports['lex-match-decimal-10'];
const lex_rule_decimal_10                             = wasmInstance.exports['lex-rule-decimal-10'];
const lex_match_decimal_10_forms                      = wasmInstance.exports['lex-match-decimal-10-forms'];
const lex_rule_decimal_10_forms                       = wasmInstance.exports['lex-rule-decimal-10-forms'];
const lex_match_dot_digits_10                         = wasmInstance.exports['lex-match-dot-digits-10'];
const lex_rule_dot_digits_10                          = wasmInstance.exports['lex-rule-dot-digits-10'];
const lex_match_digits_10                             = wasmInstance.exports['lex-match-digits-10'];
const lex_rule_digits_10                              = wasmInstance.exports['lex-rule-digits-10'];
const lex_match_digits_dot_digits_10                  = wasmInstance.exports['lex-match-digits-dot-digits-10'];
const lex_rule_digits_dot_digits_10                   = wasmInstance.exports['lex-rule-digits-dot-digits-10'];
const lex_match_maybe_digits_10                       = wasmInstance.exports['lex-match-digits-10?'];
const lex_rule_maybe_digits_10                        = wasmInstance.exports['lex-rule-digits-10?'];
const lex_match_uinteger_16                           = wasmInstance.exports['lex-match-uinteger-16'];
const lex_rule_uinteger_16                            = wasmInstance.exports['lex-rule-uinteger-16'];
const lex_match_uinteger_10                           = wasmInstance.exports['lex-match-uinteger-10'];
const lex_rule_uinteger_10                            = wasmInstance.exports['lex-rule-uinteger-10'];
const lex_match_uinteger_8                            = wasmInstance.exports['lex-match-uinteger-8'];
const lex_rule_uinteger_8                             = wasmInstance.exports['lex-rule-uinteger-8'];
const lex_match_uinteger_2                            = wasmInstance.exports['lex-match-uinteger-2'];
const lex_rule_uinteger_2                             = wasmInstance.exports['lex-rule-uinteger-2'];
const lex_match_prefix_16                             = wasmInstance.exports['lex-match-prefix-16'];
const lex_rule_prefix_16                              = wasmInstance.exports['lex-rule-prefix-16'];
const lex_match_prefix_10                             = wasmInstance.exports['lex-match-prefix-10'];
const lex_rule_prefix_10                              = wasmInstance.exports['lex-rule-prefix-10'];
const lex_match_prefix_8                              = wasmInstance.exports['lex-match-prefix-8'];
const lex_rule_prefix_8                               = wasmInstance.exports['lex-rule-prefix-8'];
const lex_match_prefix_2                              = wasmInstance.exports['lex-match-prefix-2'];
const lex_rule_prefix_2                               = wasmInstance.exports['lex-rule-prefix-2'];
const lex_match_infnan                                = wasmInstance.exports['lex-match-infnan'];
const lex_rule_infnan                                 = wasmInstance.exports['lex-rule-infnan'];
const lex_match_inf_or_nan                            = wasmInstance.exports['lex-match-inf-or-nan'];
const lex_rule_inf_or_nan                             = wasmInstance.exports['lex-rule-inf-or-nan'];
const static_string_inf                               = wasmInstance.exports['static-string-inf'];
const static_string_nan                               = wasmInstance.exports['static-string-nan'];
const lex_match_suffix                                = wasmInstance.exports['lex-match-suffix'];
const lex_rule_suffix                                 = wasmInstance.exports['lex-rule-suffix'];
const lex_match_suffix_sequence                       = wasmInstance.exports['lex-match-suffix-sequence'];
const lex_rule_suffix_sequence                        = wasmInstance.exports['lex-rule-suffix-sequence'];
const lex_match_exponent_marker                       = wasmInstance.exports['lex-match-exponent-marker'];
const lex_rule_exponent_marker                        = wasmInstance.exports['lex-rule-exponent-marker'];
const lex_match_sign                                  = wasmInstance.exports['lex-match-sign'];
const lex_rule_sign                                   = wasmInstance.exports['lex-rule-sign'];
const lex_match_exactness                             = wasmInstance.exports['lex-match-exactness'];
const lex_rule_exactness                              = wasmInstance.exports['lex-rule-exactness'];
const static_string_empty                             = wasmInstance.exports['static-string-empty'];
const static_string_exact_prefix                      = wasmInstance.exports['static-string-exact-prefix'];
const static_string_inexact_prefix                    = wasmInstance.exports['static-string-inexact-prefix'];
const lex_match_radix_2                               = wasmInstance.exports['lex-match-radix-2'];
const lex_rule_radix_2                                = wasmInstance.exports['lex-rule-radix-2'];
const static_string_radix_2                           = wasmInstance.exports['static-string-radix-2'];
const lex_match_radix_8                               = wasmInstance.exports['lex-match-radix-8'];
const lex_rule_radix_8                                = wasmInstance.exports['lex-rule-radix-8'];
const static_string_radix_8                           = wasmInstance.exports['static-string-radix-8'];
const lex_match_radix_10                              = wasmInstance.exports['lex-match-radix-10'];
const lex_rule_radix_10                               = wasmInstance.exports['lex-rule-radix-10'];
const static_string_radix_10                          = wasmInstance.exports['static-string-radix-10'];
const lex_match_radix_16                              = wasmInstance.exports['lex-match-radix-16'];
const lex_rule_radix_16                               = wasmInstance.exports['lex-rule-radix-16'];
const static_string_radix_16                          = wasmInstance.exports['static-string-radix-16'];
const lex_match_digit_2                               = wasmInstance.exports['lex-match-digit-2'];
const lex_rule_digit_2                                = wasmInstance.exports['lex-rule-digit-2'];
const lex_match_digit_8                               = wasmInstance.exports['lex-match-digit-8'];
const lex_rule_digit_8                                = wasmInstance.exports['lex-rule-digit-8'];
const lex_rule_digit_10                               = wasmInstance.exports['lex-rule-digit-10'];
const lex_match_digit_16                              = wasmInstance.exports['lex-match-digit-16'];
const lex_rule_digit_16                               = wasmInstance.exports['lex-rule-digit-16'];
const lex_match_digit_16_A_F                          = wasmInstance.exports['lex-match-digit-16/A-F'];
const lex_rule_digit_16_A_F                           = wasmInstance.exports['lex-rule-digit-16/A-F'];
const lex_match_digit_16_a_f                          = wasmInstance.exports['lex-match-digit-16/a-f'];
const lex_rule_digit_16_a_f                           = wasmInstance.exports['lex-rule-digit-16/a-f'];

_ = Object();

test_units = [
    {
        type: 'lex-rule',
        fn: lex_match_dot,
        rule_id: lex_rule_dot,
        cases: [
            [".", [_,  1]],
            ["",  [_, -1]],
            ["*", [_, -1]],
        ],
    },

    {
        type: 'lex-rule',
        fn: lex_match_dot_digits_10,
        rule_id: lex_rule_dot_digits_10,
        cases: [
            ["",      [_, -1]],
            [".",     [_, -1]],
            ["9.",    [_, -1]],
            [".7",    [_,  2]],
            [".754",  [_,  4]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_digits_10,
        rule_id: lex_rule_digits_10,
        cases: [
            ["",    [_, -1]],
            ["9",   [_,  1]],
            ["051", [_,  3]],
            ["a7",  [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_digits_dot_digits_10,
        rule_id: lex_rule_digits_dot_digits_10,
        cases: [
            ["0.",    [_,  2]],
            ["980.",  [_,  4]],
            ["9.051", [_,  5]],
            [".7",    [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_maybe_digits_10,
        rule_id: lex_rule_maybe_digits_10,
        cases: [
            ["",       [_, 0]],
            ["0",      [_, 1]],
            ["9",      [_, 1]],
            ["456989", [_, 6]],
            ["99999",  [_, 5]],
            ["a00000", [_, 0]],
            ["901d",   [_, 3]],
            ["#d0",    [_, 0]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_uinteger_16,
        rule_id: lex_rule_uinteger_16,
        cases: [
            ["",       [_, -1]],
            ["0",      [_,  1]],
            ["f",      [_,  1]],
            ["abcdef", [_,  6]],
            ["99999",  [_,  5]],
            ["-00000", [_, -1]],
            ["901g",   [_,  3]],
            ["#d0",    [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_uinteger_10,
        rule_id: lex_rule_uinteger_10,
        cases: [
            ["",       [_, -1]],
            ["0",      [_,  1]],
            ["9",      [_,  1]],
            ["456989", [_,  6]],
            ["99999",  [_,  5]],
            ["a00000", [_, -1]],
            ["901d",   [_,  3]],
            ["#d0",    [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_uinteger_8,
        rule_id: lex_rule_uinteger_8,
        cases: [
            ["",       [_, -1]],
            ["0",      [_,  1]],
            ["7",      [_,  1]],
            ["234567", [_,  6]],
            ["77777",  [_,  5]],
            ["800000", [_, -1]],
            ["701d",   [_,  3]],
            ["#o0",    [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_uinteger_2,
        rule_id: lex_rule_uinteger_2,
        cases: [
            ["",       [_, -1]],
            ["0",      [_,  1]],
            ["1",      [_,  1]],
            ["000000", [_,  6]],
            ["11111",  [_,  5]],
            ["200000", [_, -1]],
            ["101d",   [_,  3]],
            ["#b0",    [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_prefix_16,
        rule_id: lex_rule_prefix_16,
        cases: [
            ["",      [_, -1]],
            ["#i",    [_, -1]],
            ["#e",    [_, -1]],
            ["#x",    [_,  2]],
            ["#X",    [_,  2]],
            ["#x#e",  [_,  4]],
            ["#x#I",  [_,  4]],
            ["#x0",   [_,  2]],
            ["#E#x1", [_,  4]],
            ["#i#X",  [_,  4]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_prefix_10,
        rule_id: lex_rule_prefix_10,
        cases: [
            ["",      [_,  0]],
            ["#i",    [_,  2]],
            ["#e",    [_,  2]],
            ["#d",    [_,  2]],
            ["#D",    [_,  2]],
            ["#d#e",  [_,  4]],
            ["#d#I",  [_,  4]],
            ["#d0",   [_,  2]],
            ["#E#d1", [_,  4]],
            ["#i#D",  [_,  4]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_prefix_8,
        rule_id: lex_rule_prefix_8,
        cases: [
            ["",      [_, -1]],
            ["#i",    [_, -1]],
            ["#e",    [_, -1]],
            ["#o",    [_,  2]],
            ["#O",    [_,  2]],
            ["#o#e",  [_,  4]],
            ["#o#I",  [_,  4]],
            ["#o0",   [_,  2]],
            ["#E#o1", [_,  4]],
            ["#i#O",  [_,  4]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_prefix_2,
        rule_id: lex_rule_prefix_2,
        cases: [
            ["",      [_, -1]],
            ["#i",    [_, -1]],
            ["#e",    [_, -1]],
            ["#b",    [_,  2]],
            ["#B",    [_,  2]],
            ["#b#e",  [_,  4]],
            ["#b#I",  [_,  4]],
            ["#b0",   [_,  2]],
            ["#E#b1", [_,  4]],
            ["#i#B",  [_,  4]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_infnan,
        rule_id: lex_rule_infnan,
        cases: [
            ["+inf",    [_, -1]],
            ["-nan",    [_, -1]],
            ["-inf.0",  [_,  6]],
            ["+nan.0",  [_,  6]],
            ["+INF.0",  [_,  6]],
            ["-NAN.0",  [_,  6]],
            ["Inf.0",   [_, -1]],
            ["Nan.0",   [_, -1]],
            ["iNf.0",   [_, -1]],
            ["",        [_, -1]],
            ["+inf.0",  [_,  6]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_inf_or_nan,
        rule_id: lex_rule_inf_or_nan,
        cases: [
            ["inf",    [_, -1]],
            ["nan",    [_, -1]],
            ["inf.0",  [_, 5]],
            ["nan.0",  [_, 5]],
            ["INF.0",  [_, 5]],
            ["NAN.0",  [_, 5]],
            ["Inf.0",  [_, 5]],
            ["Nan.0",  [_, 5]],
            ["iNf.0",  [_, 5]],
            ["",       [_, -1]],
            ["+inf.0", [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_suffix,
        rule_id: lex_rule_suffix,
        cases: [
            ["4",    [_, 0]],
            ["",     [_, 0]],
            ["e",    [_, 0]],
            ["E",    [_, 0]],
            ["E4",   [_, 2]],
            ["E-",   [_, 0]],
            ["e+",   [_, 0]],
            ["e+0",  [_, 3]],
            ["E- 0", [_, 0]],
            ["E100", [_, 4]],
            ["E+1A", [_, 3]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_suffix_sequence,
        rule_id: lex_rule_suffix_sequence,
        cases: [
            ["4",    [_, -1]],
            ["",     [_, -1]],
            ["e",    [_, -1]],
            ["E",    [_, -1]],
            ["E4",   [_,  2]],
            ["E-",   [_, -1]],
            ["e+",   [_, -1]],
            ["e+0",  [_,  3]],
            ["E- 0", [_, -1]],
            ["E100", [_,  4]],
            ["E+1A", [_,  3]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_exponent_marker,
        rule_id: lex_rule_exponent_marker,
        cases: [
            ["4", [_, -1]],
            ["",  [_, -1]],
            ["e", [_,  1]],
            ["E", [_,  1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_sign,
        rule_id: lex_rule_sign,
        cases: [
            ["-",  [_, 1]],
            ["+",  [_, 1]],
            ["",   [_, 0]],
            ["4",  [_, 0]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_exactness,
        rule_id: lex_rule_exactness,
        cases: [
            ["#e",  [_, 2]],
            ["#i",  [_, 2]],
            ["#E",  [_, 2]],
            ["#I",  [_, 2]],
            ["#d",  [_, 0]],
            ["",    [_, 0]],
            ["#x",  [_, 0]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_radix_2,
        rule_id: lex_rule_radix_2,
        cases: [
            ["#b",  [_,  2]],
            ["#o",  [_, -1]],
            ["#d",  [_, -1]],
            ["",    [_, -1]],
            ["#x",  [_, -1]],
            ["#B",  [_,  2]],
            ["#O",  [_, -1]],
            ["#D",  [_, -1]],
            ["#X",  [_, -1]],
            [" #b", [_, -1]],
            [" #o", [_, -1]],
            [" #d", [_, -1]],
            [" #x", [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_radix_8,
        rule_id: lex_rule_radix_8,
        cases: [
            ["#b",  [_, -1]],
            ["#o",  [_,  2]],
            ["#d",  [_, -1]],
            ["",    [_, -1]],
            ["#x",  [_, -1]],
            ["#B",  [_, -1]],
            ["#O",  [_,  2]],
            ["#D",  [_, -1]],
            ["#X",  [_, -1]],
            [" #b", [_, -1]],
            [" #o", [_, -1]],
            [" #d", [_, -1]],
            [" #x", [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_radix_10,
        rule_id: lex_rule_radix_10,
        cases: [
            ["#b",  [_, 0]],
            ["#o",  [_, 0]],
            ["#d",  [_, 2]],
            ["",    [_, 0]],
            ["#x",  [_, 0]],
            ["#B",  [_, 0]],
            ["#O",  [_, 0]],
            ["#D",  [_, 2]],
            ["#X",  [_, 0]],
            [" #b", [_, 0]],
            [" #o", [_, 0]],
            [" #d", [_, 0]],
            [" #x", [_, 0]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_radix_16,
        rule_id: lex_rule_radix_16,
        cases: [
            ["#b",  [_, -1]],
            ["#o",  [_, -1]],
            ["#d",  [_, -1]],
            ["",    [_, -1]],
            ["#x",  [_,  2]],
            ["#B",  [_, -1]],
            ["#O",  [_, -1]],
            ["#D",  [_, -1]],
            ["#X",  [_,  2]],
            [" #b", [_, -1]],
            [" #o", [_, -1]],
            [" #d", [_, -1]],
            [" #x", [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_digit_8,
        rule_id: lex_rule_digit_8,
        cases: [
            ["0",  [_,  1]],
            ["",   [_, -1]],
            ["F",  [_, -1]],
            ["/",  [_, -1]],
            [":",  [_, -1]],
            [" 6", [_, -1]],
            ["1",  [_,  1]],
            ["2",  [_,  1]],
            ["3",  [_,  1]],
            ["4",  [_,  1]],
            ["5",  [_,  1]],
            ["6",  [_,  1]],
            ["7",  [_,  1]],
            ["8",  [_, -1]],
            ["9",  [_, -1]],
            [".",  [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_digit,
        rule_id: lex_rule_digit,
        cases: [
            ["0",  [_,  1]],
            ["",   [_, -1]],
            ["F",  [_, -1]],
            ["/",  [_, -1]],
            [":",  [_, -1]],
            [" 6", [_, -1]],
            ["1",  [_,  1]],
            ["2",  [_,  1]],
            ["3",  [_,  1]],
            ["4",  [_,  1]],
            ["5",  [_,  1]],
            ["6",  [_,  1]],
            ["7",  [_,  1]],
            ["8",  [_,  1]],
            ["9",  [_,  1]],
            [".",  [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_digit_16,
        rule_id: lex_rule_digit_16,
        cases: [
            ["A",  [lex_rule_digit_16_A_F,  1]],
            ["",   [_,                     -1]],
            ["B",  [lex_rule_digit_16_A_F,  1]],
            ["C",  [lex_rule_digit_16_A_F,  1]],
            ["D",  [lex_rule_digit_16_A_F,  1]],
            ["E",  [lex_rule_digit_16_A_F,  1]],
            ["F",  [lex_rule_digit_16_A_F,  1]],
            [" A", [_,                     -1]],
            ["1",  [lex_rule_digit,         1]],
            ["a",  [lex_rule_digit_16_a_f,  1]],
            ["2",  [lex_rule_digit,         1]],
            ["3",  [lex_rule_digit,         1]],
            ["4",  [lex_rule_digit,         1]],
            ["5",  [lex_rule_digit,         1]],
            ["6",  [lex_rule_digit,         1]],
            ["7",  [lex_rule_digit,         1]],
            ["8",  [lex_rule_digit,         1]],
            ["9",  [lex_rule_digit,         1]],
            [".",  [_,                     -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_digit_16_A_F,
        rule_id: lex_rule_digit_16_A_F,
        cases: [
            ["A",  [_,  1]],
            ["",   [_, -1]],
            ["B",  [_,  1]],
            ["C",  [_,  1]],
            ["D",  [_,  1]],
            ["E",  [_,  1]],
            ["F",  [_,  1]],
            ["@",  [_, -1]],
            ["G",  [_, -1]],
            [" A", [_, -1]],
            ["1",  [_, -1]],
            ["a",  [_, -1]],
        ],
    },
    {
        type: 'lex-rule',
        fn: lex_match_digit_16_a_f,
        rule_id: lex_rule_digit_16_a_f,
        cases: [
            ["a",  [_,  1]],
            ["",   [_, -1]],
            ["b",  [_,  1]],
            ["c",  [_,  1]],
            ["d",  [_,  1]],
            ["e",  [_,  1]],
            ["f",  [_,  1]],
            ["`",  [_, -1]],
            ["g",  [_, -1]],
            [" a", [_, -1]],
            ["1",  [_, -1]],
            ["A",  [_, -1]],
        ],
    }
]

function run_tests() {

    for (let i in test_units) {

        let { fn, rule_id, cases } = test_units[i];

        for (j in cases) {

            let [ text, [ expected_rule_id, expected_end ] ]  = cases[j];

            if (expected_rule_id == _) {
                expected_rule_id = rule_id.value;
            }

            set_test_text(text);

            try {
                let [ actual_rule_id, actual_end_addr ] = fn(rule_id, test_text_addr, test_text_addr+text.length);

                let actual_end = actual_end_addr > 0 ? actual_end_addr - test_text_addr : actual_end_addr;

                if (expected_rule_id != actual_rule_id) {
                    console.log(`test unit ${i} case ${j}: rule mismatch: expected ${expected_rule_id}, actual ${actual_rule_id}.`);
                }

                if (expected_end != actual_end) {
                    console.log(`test unit ${i} case ${j}: end mismatch: expected ${expected_end}, actual ${actual_end}.`);
                }
            }
            catch (e) {
                console.log(`test unit ${i} case ${j}: raised an exception ${e}.`);
            }
        }
    }
}

const test_text_addr = 0x1000;
const test_text = new Uint8Array(memory.buffer);

let utf8_encoder = new TextEncoder();

function set_test_text(t) {
    test_text.set(utf8_encoder.encode(t), test_text_addr);
}

run_tests();

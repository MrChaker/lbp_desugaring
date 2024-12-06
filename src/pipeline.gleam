import desugarers/absorb_next_sibling_while.{absorb_next_sibling_while}
import desugarers/add_counter_attributes.{add_counter_attributes}
import desugarers/add_exercise_labels.{add_exercise_labels}
import desugarers/add_spacer_divs_before.{add_spacer_divs_before}
import desugarers/add_spacer_divs_between.{add_spacer_divs_between}
import desugarers/add_title_counters_and_titles_with_handle_assignments.{
  add_title_counters_and_titles_with_handle_assignments,
}
import desugarers/change_attribute_value.{change_attribute_value}
import desugarers/concatenate_text_nodes.{concatenate_text_nodes}
import desugarers/convert_int_attributes_to_float.{
  convert_int_attributes_to_float,
}
import desugarers/counter.{counter_desugarer}
import desugarers/counter_handles.{counter_handles_desugarer}
import desugarers/fold_tags_into_text.{fold_tags_into_text}
import desugarers/free_children.{free_children}
import desugarers/insert_indent.{insert_indent}
import desugarers/pair_bookends.{pair_bookends}
import desugarers/reinsert_math_dolar.{reinsert_math_dolar}
import desugarers/remove_empty_lines.{remove_empty_lines}
import desugarers/remove_vertical_chunks_with_no_text_child.{
  remove_vertical_chunks_with_no_text_child,
}
import desugarers/split_by_indexed_regexes.{split_by_indexed_regexes}
import desugarers/split_vertical_chunks.{split_vertical_chunks}
import desugarers/unwrap_tags.{unwrap_tags}
import desugarers/wrap_element_children.{wrap_element_children_desugarer}
import desugarers/wrap_elements_by_blankline.{wrap_elements_by_blankline}
import desugarers/wrap_math_with_no_break.{wrap_math_with_no_break}
import gleam/dict
import gleam/regex
import infrastructure.{type Pipe} as infra

pub fn pipeline_constructor() -> List(Pipe) {
  let double_dollar_indexed_regex = #(
    infra.unescaped_suffix_regex("(\\$\\$)"),
    1,
    2,
  )

  let single_dollar_indexed_regex = #(
    infra.unescaped_suffix_regex("(\\$)"),
    1,
    2,
  )

  let opening_double_underscore_indexed_regex = #(
    {
      let assert Ok(re) =
        regex.from_string("(\\s)(__)(\\w|[“‘~\\*\\(\\[{]|$)")
      re
    },
    1,
    3,
  )

  let opening_or_closing_double_underscore_indexed_regex = #(
    {
      let assert Ok(re) =
        regex.from_string(
          "(\\w|[”’~\\.\\?\\!\\*\\)\\]}]|^)(__)(\\w|[“‘~\\*\\(\\[{]|$)",
        )
      re
    },
    1,
    3,
  )

  let closing_double_underscore_indexed_regex = #(
    {
      let assert Ok(re) =
        regex.from_string("(\\w|[”’~\\.\\?\\!\\*\\)\\]}]|^)(__)(\\s)")
      re
    },
    1,
    3,
  )

  let opening_central_quote_indexed_regex = #(
    {
      let assert Ok(re) =
        regex.from_string("(\\s|^)(_\\|)(\\w|[“‘_~\\.\\?\\!\\*\\(\\[{]|$)")
      re
    },
    1,
    3,
  )

  let closing_central_quote_indexed_regex = #(
    {
      let assert Ok(re) =
        regex.from_string("(\\w|[”’_~\\.\\?\\!\\*\\)\\]}]|^)(\\|_)(\\s|$)")
      re
    },
    1,
    3,
  )

  let opening_single_underscore_indexed_regex = #(
    {
      let assert Ok(re) =
        regex.from_string("(\\s)(_)(\\w|[“‘~\\*\\(\\[{]|$)")
      re
    },
    1,
    3,
  )

  let opening_or_closing_single_underscore_indexed_regex = #(
    {
      let assert Ok(re) =
        regex.from_string(
          "(\\w|[”’~\\.\\?\\!\\(\\[{]|^)(_)(\\w|[“‘~\\.\\?\\!\\)\\]}]|$)",
        )
      re
    },
    1,
    3,
  )

  let opening_or_closing_single_underscore_indexed_regex_with_asterisks = #(
    {
      let assert Ok(re) =
        regex.from_string(
          "(\\w|[”’~\\.\\?\\!\\*\\(\\[{]|^)(_)(\\w|[“‘~\\.\\?\\!\\*\\)\\]}]|$)",
        )
      re
    },
    1,
    3,
  )

  let closing_single_underscore_indexed_regex = #(
    {
      let assert Ok(re) =
        regex.from_string("(\\w|[”’~\\.\\?\\!\\*\\(\\[{]|^)(_)(\\s)")
      re
    },
    1,
    3,
  )

  let opening_single_asterisk_indexed_regex = #(
    {
      let assert Ok(re) =
        regex.from_string("(\\s)(\\*)(\\w|[“‘_~\\(\\[{]|$)")
      re
    },
    1,
    3,
  )

  let opening_or_closing_single_asterisk_indexed_regex = #(
    {
      let assert Ok(re) =
        regex.from_string(
          "(\\w|[”’~\\._\\(\\[{]|^)(\\*)(\\w|[“‘_~\\.\\?\\!\\)\\]}]|$)",
        )
      re
    },
    1,
    3,
  )

  let closing_single_asterisk_indexed_regex = #(
    {
      let assert Ok(re) =
        regex.from_string("(\\w|[”’~\\._\\(\\[{]|^)(\\*)(\\s)")
      re
    },
    1,
    3,
  )

  [
    unwrap_tags(["WriterlyBlurb"]),
    convert_int_attributes_to_float([#("", "line"), #("", "padding_left")]),
    // ************************
    // $$ *********************
    // ************************
    split_by_indexed_regexes(
      #([#(double_dollar_indexed_regex, "DoubleDollar")], []),
    ),
    pair_bookends(#(["DoubleDollar"], ["DoubleDollar"], "MathBlock")),
    fold_tags_into_text(dict.from_list([#("DoubleDollar", "$$")])),
    remove_empty_lines(),
    // ************************
    // AddTitleCounters *******
    // ************************
    add_title_counters_and_titles_with_handle_assignments([
      #("Chapter", "ExampleCounter", "Example", "*Example ", ".*", "*Example.*"),
      #("Chapter", "NoteCounter", "Note", "_Note ", "._", "_Note._"),
      #(
        "Exercises",
        "ExerciseCounter",
        "Exercise",
        "*Exercise ",
        ".*",
        "*Exercise.*",
      ),
      #("Solution", "SolutionNoteCounter", "Note", "_Note ", "._", "_Note._"),
    ]),
    // ************************
    // VerticalChunk **********
    // ************************
    wrap_elements_by_blankline([
      "MathBlock", "Image", "Table", "Exercises", "Solution", "Example",
      "Section", "Exercise", "List", "Grid", "ImageLeft", "ImageRight",
    ]),
    split_vertical_chunks(["MathBlock"]),
    remove_vertical_chunks_with_no_text_child(),
    // ************************
    // $ **********************
    // ************************
    split_by_indexed_regexes(
      #([#(single_dollar_indexed_regex, "SingleDollar")], ["MathBlock"]),
    ),
    pair_bookends(#(["SingleDollar"], ["SingleDollar"], "Math")),
    fold_tags_into_text(dict.from_list([#("SingleDollar", "$")])),
    // ************************
    // __ *********************
    // ************************
    split_by_indexed_regexes(
      #(
        [
          #(
            opening_or_closing_double_underscore_indexed_regex,
            "OpeningOrClosingDoubleUnderscore",
          ),
          #(opening_double_underscore_indexed_regex, "OpeningDoubleUnderscore"),
          #(closing_double_underscore_indexed_regex, "ClosingDoubleUnderscore"),
        ],
        ["MathBlock", "Math"],
      ),
    ),
    pair_bookends(#(
      ["OpeningDoubleUnderscore", "OpeningOrClosingDoubleUnderscore"],
      ["ClosingDoubleUnderscore", "OpeningOrClosingDoubleUnderscore"],
      "CentralItalicDisplay",
    )),
    fold_tags_into_text(
      dict.from_list([
        #("OpeningDoubleUnderscore", "__"),
        #("ClosingDoubleUnderscore", "__"),
      ]),
    ),
    // ************************
    // _| |_ ******************
    // ************************
    split_by_indexed_regexes(
      #(
        [
          #(opening_central_quote_indexed_regex, "OpeningCenterQuote"),
          #(closing_central_quote_indexed_regex, "ClosingCenterQuote"),
        ],
        ["MathBlock"],
      ),
    ),
    pair_bookends(#(
      ["OpeningCenterQuote"],
      ["ClosingCenterQuote"],
      "CenterDisplay",
    )),
    fold_tags_into_text(
      dict.from_list([
        #("OpeningCenterQuote", "_|"),
        #("ClosingCenterQuote", "|_"),
      ]),
    ),
    // ************************
    // break CenterDisplay &
    // CentralItalicDisplay out
    // of VerticalChunk
    // ************************
    free_children([
      #("CenterDisplay", "VerticalChunk"),
      #("CentralItalicDisplay", "VerticalChunk"),
    ]),
    remove_vertical_chunks_with_no_text_child(),
    // ************************
    // _ & * ******************
    // ************************
    split_by_indexed_regexes(
      #(
        [
          #(
            opening_or_closing_single_underscore_indexed_regex,
            "OpeningOrClosingUnderscore",
          ),
          #(opening_single_underscore_indexed_regex, "OpeningUnderscore"),
          #(closing_single_underscore_indexed_regex, "ClosingUnderscore"),
          #(
            opening_or_closing_single_asterisk_indexed_regex,
            "OpeningOrClosingAsterisk",
          ),
          #(opening_single_asterisk_indexed_regex, "OpeningAsterisk"),
          #(closing_single_asterisk_indexed_regex, "ClosingAsterisk"),
          #(
            opening_or_closing_single_underscore_indexed_regex_with_asterisks,
            "OpeningOrClosingUnderscore",
          ),
          #(opening_single_underscore_indexed_regex, "OpeningUnderscore"),
          #(closing_single_underscore_indexed_regex, "ClosingUnderscore"),
        ],
        ["MathBlock", "Math"],
      ),
    ),
    pair_bookends(#(
      ["OpeningUnderscore", "OpeningOrClosingUnderscore"],
      ["ClosingUnderscore", "OpeningOrClosingUnderscore"],
      "i",
    )),
    pair_bookends(#(
      ["OpeningAsterisk", "OpeningOrClosingAsterisk"],
      ["ClosingAsterisk", "OpeningOrClosingAsterisk"],
      "b",
    )),
    fold_tags_into_text(
      dict.from_list([
        #("OpeningOrClosingUnderscore", "_"),
        #("OpeningUnderscore", "_"),
        #("ClosingUnderscore", "_"),
        #("OpeningOrClosingAsterisk", "*"),
        #("OpeningAsterisk", "*"),
        #("ClosingAsterisk", "*"),
      ]),
    ),
    // ************************
    // misc *******************
    // ************************
    wrap_math_with_no_break(),
    insert_indent(),
    wrap_element_children_desugarer(#(["List", "Grid"], "Item")),
    counter_desugarer(),
    counter_handles_desugarer(),
    add_exercise_labels(),
    add_counter_attributes([#("Solution", "Exercises", "solution_number", 0)]),
    concatenate_text_nodes(),
    reinsert_math_dolar(),
    absorb_next_sibling_while([
      #("VerticalChunk", "ImageRight"),
      #("VerticalChunk", "ImageLeft"),
      #("MathBlock", "ImageRight"),
      #("MathBlock", "ImageLeft"),
      #("CentralItalicDisplay", "ImageRight"),
      #("CentralItalicDisplay", "ImageLeft"),
      #("CentralDisplay", "ImageRight"),
      #("CentralDisplay", "ImageLeft"),
    ]),
    change_attribute_value([#("src", "/()")]),
    // ************************
    // Add spacers
    // ************************
    add_spacer_divs_between([
      #(#("MathBlock", "VerticalChunk"), "spacer"),
      #(#("Example", "VerticalChunk"), "spacer"),
      #(#("Image", "VerticalChunk"), "spacer"),
      #(#("Table", "VerticalChunk"), "spacer"),
      #(#("table", "VerticalChunk"), "spacer"),
      #(#("Grid", "VerticalChunk"), "spacer"),
      #(#("CentralItalicDisplay", "VerticalChunk"), "spacer"),
    ]),
    add_spacer_divs_before([
      #("Exercises", "spacer"),
      #("Example", "spacer"),
      #("Note", "spacer"),
      #("Section", "spacer"),
      #("MathBlock", "spacer"),
      #("Image", "spacer"),
      #("Table", "spacer"),
      #("table", "spacer"),
      #("Grid", "spacer"),
      #("Solution", "spacer"),
    ]),
  ]
}

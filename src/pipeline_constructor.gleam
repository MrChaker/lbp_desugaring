import desugarers_docs

import node_to_node_transforms/wrap_element_children_transform.{
  WrapElementChildrenExtra,
}
import node_to_nodes_transforms/split_delimiters_chunks_transform.{
  SplitDelimitersChunksExtraArgs,
}
import node_to_nodes_transforms/wrap_elements_by_blankline_transform.{
  WrapByBlankLineExtraArgs,
}

pub fn pipeline_constructor() {
  let extra_1 =
    WrapElementChildrenExtra(element_tags: ["List", "Grid"], wrap_with: "Item")

  let extra_2 =
    WrapByBlankLineExtraArgs(tags: [
      "MathBlock", "Image", "Table", "Exercises", "Solution", "Example",
      "Section", "Exercise", "List", "Grid",
    ])

  let extra_3 =
    SplitDelimitersChunksExtraArgs(
      open_delimiter: "__",
      close_delimiter: "__",
      tag_name: "CentralItalicDisplay",
      splits_chunks: True,
      can_be_nested_inside: [],
    )

  let extra_4 =
    SplitDelimitersChunksExtraArgs(
      open_delimiter: "_|",
      close_delimiter: "|_",
      tag_name: "CentralDisplay",
      splits_chunks: True,
      can_be_nested_inside: [],
    )

  let extra_5 =
    SplitDelimitersChunksExtraArgs(
      open_delimiter: "_",
      close_delimiter: "_",
      tag_name: "i",
      splits_chunks: False,
      can_be_nested_inside: ["*"],
    )

  let extra_6 =
    SplitDelimitersChunksExtraArgs(
      open_delimiter: "*",
      close_delimiter: "*",
      tag_name: "b",
      splits_chunks: False,
      can_be_nested_inside: ["i"],
    )

  let extra_7 =
    SplitDelimitersChunksExtraArgs(
      open_delimiter: "$",
      close_delimiter: "$",
      tag_name: "Math",
      splits_chunks: False,
      can_be_nested_inside: ["i", "*"],
    )

  [
    desugarers_docs.remove_writerly_blurb_tags_around_text_nodes_pipe(),
    desugarers_docs.break_up_text_by_double_dollars_pipe(),
    desugarers_docs.pair_double_dollars_together_pipe(),
    desugarers_docs.wrap_elements_by_blankline_pipe(extra_2),
    desugarers_docs.split_vertical_chunks_pipe(),
    desugarers_docs.remove_vertical_chunks_with_no_text_child_pipe(),
    desugarers_docs.insert_indent_pipe(),
    desugarers_docs.wrap_element_children_pipe(extra_1),
    desugarers_docs.split_delimiters_chunks_pipe(extra_3),
    desugarers_docs.split_delimiters_chunks_pipe(extra_4),
    desugarers_docs.split_delimiters_chunks_pipe(extra_5),
    desugarers_docs.split_delimiters_chunks_pipe(extra_6),
    desugarers_docs.split_delimiters_chunks_pipe(extra_7),
    desugarers_docs.wrap_math_with_no_break_pipe(),
  ]
}

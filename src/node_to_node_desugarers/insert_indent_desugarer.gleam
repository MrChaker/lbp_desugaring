import infrastructure.{fancy_depth_first_node_to_node_desugarer}
import node_to_node_transforms/insert_indent_transform.{insert_indent_transform}
import vxml_parser.{type VXML}

pub fn insert_indent_desugarer(vxml: VXML) {
  fancy_depth_first_node_to_node_desugarer(vxml, insert_indent_transform, Nil)
}
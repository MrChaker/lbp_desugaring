import gleam/list
import gleam/option
import infrastructure.{
  type Desugarer, type DesugaringError, type NodeToNodesTransform, type Pipe,
  DesugarerDescription, DesugaringError, depth_first_node_to_nodes_desugarer,
}
import vxml_parser.{type VXML, V}

pub fn remove_tag_transform(
  vxml: VXML,
  extra: List(String),
) -> Result(List(VXML), DesugaringError) {
  case vxml {
    V(_, tag, _, _) ->
      case list.contains(extra, tag) {
        True -> Ok([])
        False -> Ok([vxml])
      }
    _ -> Ok([vxml])
  }
}

fn transform_factory(extra: List(String)) -> NodeToNodesTransform {
  fn(node) { remove_tag_transform(node, extra) }
}

fn desugarer_factory(extra: List(String)) -> Desugarer {
  fn(vxml) {
    depth_first_node_to_nodes_desugarer(vxml, transform_factory(extra))
  }
}

pub fn remove_tag_desugarer(extra: List(String)) -> Pipe {
  #(
    DesugarerDescription("remove_tag_desugarer", option.None, "..."),
    desugarer_factory(extra),
  )
}
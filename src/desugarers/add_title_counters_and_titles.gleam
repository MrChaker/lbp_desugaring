import gleam/list
import gleam/option.{Some}
import gleam/pair
import gleam/string
import infrastructure.{
  type Desugarer, type DesugaringError, type Pipe, DesugarerDescription,
  DesugaringError,
} as infra
import vxml_parser.{type VXML, BlamedAttribute, BlamedContent, T, V}

const ins = string.inspect

fn param_transform(
  node: VXML,
  ancestors: List(VXML),
  _: List(VXML),
  _: List(VXML),
  _: List(VXML),
  tuples: Extra,
) -> Result(VXML, DesugaringError) {
  case node {
    T(_, _) -> Ok(node)
    V(blame, tag, _, children) -> {
      let new_node = {
        tuples
        |> list.map_fold(from: node, with: fn(current_node, tuple) -> #(
          VXML,
          Nil,
        ) {
          let #(parent, counter_name, _, _, _) = tuple
          let assert V(_, _, current_attributes, _) = current_node
          case parent == tag {
            False -> #(current_node, Nil)
            True -> {
              let new_attribute =
                BlamedAttribute(blame, "counter", counter_name)
              #(
                V(blame, tag, [new_attribute, ..current_attributes], children),
                Nil,
              )
            }
          }
        })
        |> pair.first
      }
      let newest_node = {
        tuples
        |> list.map_fold(from: new_node, with: fn(current_node, tuple) -> #(
          VXML,
          Nil,
        ) {
          let #(tag_that_declared_counter, counter_name, node_name, pre, post) =
            tuple
          case
            node_name == tag
            && list.any(ancestors, fn(ancestor) {
              let assert V(_, name, _, _) = ancestor
              name == tag_that_declared_counter
            })
          {
            False -> #(current_node, Nil)
            True -> {
              let assert V(_, _, newest_attributes, current_children) =
                current_node
              let new_children = [
                T(blame, [
                  BlamedContent(blame, pre <> "::++" <> counter_name <> post),
                ]),
                ..current_children
              ]
              #(V(blame, tag, newest_attributes, new_children), Nil)
            }
          }
        })
        |> pair.first
      }
      Ok(newest_node)
    }
  }
}

//**********************************
// type Extra = List(#(String,         String,       String,        String,         String))
//                       ↖ parent or     ↖ counter     ↖ element     ↖ pre-counter     ↖ post-counter
//                         ancestor        name          to add        phrase            phrase
//                         tag that                      title to
//                         contains
//                         counter
//**********************************

type Extra =
  List(#(String, String, String, String, String))

fn transform_factory(extra: Extra) -> infra.NodeToNodeFancyTransform {
  fn(node, ancestors, s1, s2, s3) {
    param_transform(node, ancestors, s1, s2, s3, extra)
  }
}

fn desugarer_factory(extra: Extra) -> Desugarer {
  infra.node_to_node_fancy_desugarer_factory(transform_factory(extra))
}

pub fn add_title_counters_and_titles(extra: Extra) -> Pipe {
  #(
    DesugarerDescription(
      "add_title_counters_and_titles",
      Some(ins(extra)),
      "...",
    ),
    desugarer_factory(extra),
  )
}
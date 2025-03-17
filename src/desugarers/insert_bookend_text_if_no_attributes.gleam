import gleam/pair
import gleam/list
import gleam/option
import infrastructure.{ type Desugarer, type DesugaringError, type Pipe, Pipe, DesugarerDescription, DesugaringError } as infra
import vxml_parser.{type VXML, V}

fn param_transform(vxml: VXML, extra: Param) -> Result(VXML, DesugaringError) {
  case vxml {
    V(_, tag, [], _) -> {
      case list.find(extra, fn(pair) { pair |> pair.first == tag }) {
        Error(Nil) -> Ok(vxml)
        Ok(#(_, #(start_text, end_text))) -> {
          vxml
          |> infra.v_start_insert_text(start_text)
          |> infra.v_end_insert_text(end_text)
          |> Ok
        }
      }
    }
    _ -> Ok(vxml)
  }
}

fn transform_factory(param: Param) -> infra.NodeToNodeTransform {
  param_transform(_, param)
}

fn desugarer_factory(param: Param) -> Desugarer {
  infra.node_to_node_desugarer_factory(transform_factory(param))
}

fn param(extra: Extra) -> Param {
  extra
  |> list.map(
    fn (triple) {
      let #(a, b, c) = triple
      #(a, #(b, c))
    }
  )
}

type Param = List(#(String, #(String, String)))
type Extra = List(#(String, String, String))

pub fn insert_bookend_text_if_no_attributes(extra: Extra) -> Pipe {
  Pipe(
    description: DesugarerDescription("insert_bookend_text_if_no_attributes", option.None, "..."),
    desugarer: desugarer_factory(extra |> param),
  )
}

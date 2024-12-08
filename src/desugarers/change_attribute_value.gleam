import gleam/list
import gleam/option
import gleam/string
import infrastructure.{
  type Desugarer, type DesugaringError, type NodeToNodeTransform, type Pipe,
  DesugarerDescription,
} as infra
import vxml_parser.{type BlamedAttribute, type VXML, BlamedAttribute, T, V}

fn replace_value(value: String, replacement: String) -> String {
  string.replace(replacement, "()", value)
}

fn update_attributes(
  attributes: List(BlamedAttribute),
  extra: Extra,
) -> List(BlamedAttribute) {
  case attributes {
    [] -> attributes
    [first, ..rest] -> {
      case
        extra
        |> list.find(fn(x) {
          let #(key, _) = x
          key == first.key
        })
      {
        Ok(#(_, replacement)) -> {
          [
            BlamedAttribute(
              ..first,
              value: replace_value(first.value, replacement),
            ),
            ..update_attributes(rest, extra)
          ]
        }
        Error(_) -> [first, ..update_attributes(rest, extra)]
      }
    }
  }
}

fn change_attribute_value_param_transform(
  vxml: VXML,
  extra: Extra,
) -> Result(VXML, DesugaringError) {
  case vxml {
    T(_, _) -> Ok(vxml)
    V(blame, tag, attributes, children) -> {
      Ok(V(blame, tag, update_attributes(attributes, extra), children))
    }
  }
}

//**********************************
// type Extra = List(#(String,            String  ))
//                       ↖ attribute key      ↖ replacement of attribute value string
//                                              "()" can be used to keep current value
//                                              ex: 
//                                                current value: image/img.png 
//                                                replacement: /() 
//                                                result: /image/img.png
//**********************************
type Extra =
  List(#(String, String))

fn transform_factory(extra: Extra) -> NodeToNodeTransform {
  change_attribute_value_param_transform(_, extra)
}

fn desugarer_factory(extra: Extra) -> Desugarer {
  infra.node_to_node_desugarer_factory(transform_factory(extra))
}

pub fn change_attribute_value(extra: Extra) -> Pipe {
  #(
    DesugarerDescription(
      "change_attribute_value",
      option.Some(string.inspect(extra)),
      "...",
    ),
    desugarer_factory(extra),
  )
}
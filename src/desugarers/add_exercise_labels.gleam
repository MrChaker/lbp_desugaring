import gleam/list
import gleam/option
import gleam/string
import infrastructure.{
  type Desugarer, type DesugaringError, type NodeToNodeTransform, type Pipe,
  DesugarerDescription,
} as infra
import vxml_parser.{type BlamedAttribute, type VXML, BlamedAttribute, V}

fn add_exercise_labels_transform(vxml: VXML) -> Result(VXML, DesugaringError) {
  case vxml {
    V(blame, "Exercises", attributes, children) -> {
      let new_attribute = [
        BlamedAttribute(
          blame,
          "labels",
          "vec!"
            <> string.inspect(
            list.index_map(children, fn(_, i) { string.inspect(i) }),
          ),
        ),
      ]
      Ok(V(
        blame,
        "Exercises",
        list.flatten([new_attribute, attributes]),
        children,
      ))
    }
    _ -> Ok(vxml)
  }
}

fn transform_factory() -> NodeToNodeTransform {
  add_exercise_labels_transform(_)
}

fn desugarer_factory() -> Desugarer {
  infra.node_to_node_desugarer_factory(transform_factory())
}

pub fn add_exercise_labels() -> Pipe {
  #(
    DesugarerDescription("add_exercise_labels", option.None, "..."),
    desugarer_factory(),
  )
}
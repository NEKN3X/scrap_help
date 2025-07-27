import core/help
import gleam/javascript/promise

pub type GetAllHelps {
  GetAllHelps(run: fn(List(String)) -> promise.Promise(List(help.Help)))
}

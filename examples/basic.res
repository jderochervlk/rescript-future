// let _ =
//   Future.make(() => Promise.make((res, _rej) => res(42)))
//   ->Future.map(res => res + 1)
//   ->Future.fold(_ => Console.error("bad"), _ => Console.log("farts"))
Console.log("running")

let fn = async () => {
  let _ = try {
    await Future.make(() => Promise.make((_res, rej) => rej(Exn.raiseError("There was a problem"))))
    ->Future.map(res => res + 1)
    ->Future.fold(
      (e: Exn.t) =>
        Console.error("Exception was not raised and error is handled by the fold function."),
      Console.log,
    )
  } catch {
  | _ => Console.error("never logs")
  }
}

let _ = fn()

// promise will throw an error
let fn = async () => {
  let _ = try {
    await Promise.make((_res, rej) => rej(Exn.raiseError("There was a problem")))
  } catch {
  | _ => Console.error("Exception was thrown and this logs")
  }
}

let _ = fn()

// /** Inline promise */
// let _ = Future.make(() => Webapi.Fetch.fetch(""))->Future.fold(
//   e => Console.error(e),
//   _ => Console.log("oops"),
// )

/** Inline promise */
let _ =
  Future.make(() => Promise.make((res, _rej) => res(42)))
  ->Future.map(res => res + 1)
  ->Future.fold(Console.error, Console.log)

let _ =
  Future.make(() => Promise.make((_res, rej) => rej(Exn.raiseError("There was a problem"))))
  ->Future.map(res => res + 1)
  ->Future.fold(Console.error, Console.log)

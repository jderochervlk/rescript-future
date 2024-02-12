// example with 2 good results
let a = Future.make(() => Promise.resolve(1))
// let _ = Future.all2((a, a))->Future.fold(Console.error, Console.log)

// // example with 1 bad result
// let b = Future.make(() => Promise.reject(Exn.raiseError("There was an error")))
// let _ = Future.all2((a, b))->Future.fold(Console.error, Console.log)

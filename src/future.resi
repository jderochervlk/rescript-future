// A lazy value that holds an asynchronous action that might result in failure.
type future<'a, 'e> = unit => promise<result<'a, 'e>>

/**
 Create a `future` from a lazy function that returns a `promise`.
 
 ```rescript
  let request = Future.make(() => Webapi.Fetch.fetch("http://httpstat.us/200"))
 ```
 */
let make: (unit => promise<'a>) => future<'a, 'e>

/**
 Apply a function to the `Ok` value in a `future`. 
 If the value is an `Error` the function will not run.

```rescript
let _ =
  Future.make(() => Promise.make((res, _rej) => res(42)))
  ->Future.map(res => res + 1) // value is now 43
```
 */
let map: (future<'a, 'e>, 'a => 'b) => future<'b, 'e>

/**
 Apply a function to the `Error` value in a `future`. 
 If the value is `Ok` the function will not run.

```rescript
let number =
  Future.make(() => Promise.make((_res, rej) => rej({"message": "There was an error"})))
  ->Future.mapError(err => err["message"])
```
 */
let mapError: (future<'a, 'e>, 'e => 'b) => future<'a, 'b>
let mapPromise: (future<'a, 'e>, 'a => promise<'b>) => future<'d, 'e>
let flatMap: (future<'a, 'f>, 'a => result<'b, 'f>) => future<'b, 'f>

type successFn<'a, 'b> = 'a => 'b
type errorFn<'a, 'b> = 'a => 'b
let fold: (future<'t, 'f>, errorFn<'f, 'u>, successFn<'t, 'u>) => RescriptCore.Promise.t<'u>
let run: future<'a, 'e> => promise<result<'a, 'e>>
let all2: ((future<'a, 'e>, future<'b, 'f>)) => future<('a, 'b), (option<'e>, option<'f>)>
let all3: ((future<'a, 'e>, future<'b, 'f>, future<'c, 'e>)) => future<
  ('a, 'b, 'c),
  (option<'e>, option<'f>, option<'e>),
>

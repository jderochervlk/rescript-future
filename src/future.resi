/**
 Similar to the existing result type with with a Cancelled variant
 */
type result<'a, 'e> = Ok('a) | Error('e) | Cancelled

/**
 lazy value that holds an asynchronous action that might result in failure.
 */
type future<'a, 'e> = {
  value: unit => promise<result<'a, 'e>>,
  cancelled: ref<bool>,
  controller: option<Webapi.Fetch.AbortController.t>,
}

/**
 Create a `future` from a lazy function that returns a `promise`.
 
 ```rescript
  let request = Future.make(() => Webapi.Fetch.fetch("http://httpstat.us/200"))
 ```
 */
let make: (unit => promise<'a>, ~controller: Webapi.Fetch.AbortController.t=?) => future<'a, 'e>

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
type successFn<'a> = 'a => unit
type errorFn<'a> = 'a => unit
let fold: (future<'t, 'f>, errorFn<'f>, successFn<'t>) => RescriptCore.Promise.t<unit>
let run: future<'a, 'e> => promise<result<'a, 'e>>
let cancel: future<'a, 'e> => unit
let all2: ((future<'a, 'e>, future<'b, 'f>)) => future<('a, 'b), (option<'e>, option<'f>)>
let all3: ((future<'a, 'e>, future<'b, 'f>, future<'c, 'e>)) => future<
  ('a, 'b, 'c),
  (option<'e>, option<'f>, option<'e>),
>
let fetch: string => future<Webapi.Fetch.response, 'a>

@send
external safeCatch: (promise<'a>, 'e => result<'a, 'e>) => 'e = "catch"

type result<'a, 'e> =
  | Ok('a)
  | Error('e)
  | Cancelled

type future<'a, 'e> = {value: unit => promise<result<'a, 'e>>, cancelled: ref<bool>}

let make = (lazyPromise: unit => promise<'a>, ~cancelled: option<ref<bool>>=?): future<'a, 'e> => {
  let cancelled = cancelled->Option.getOr(ref(false))
  {
    value: () => {
      try {
        lazyPromise()
      } catch {
      | e => Promise.make((_, rej) => rej(e))
      }
      ->Promise.thenResolve(t => Ok(t))
      ->safeCatch(e => Error(e))
    },
    cancelled,
  }
}

let map = (future: future<'a, 'e>, fn: 'a => 'b): future<'b, 'e> => {
  value: () =>
    future.value()->Promise.thenResolve(t =>
      switch t {
      | Cancelled => Cancelled
      | Ok(t) =>
        switch future.cancelled.contents {
        | false => Ok(fn(t))
        | true => Cancelled
        }
      | Error(e) => Error(e)
      }
    ),
  cancelled: future.cancelled,
}
type successFn<'a> = 'a => unit
type errorFn<'a> = 'a => unit
type cancelledFn = unit => unit

let fold = (
  future: future<'a, 'e>,
  errorFn: errorFn<'f>,
  successFn: successFn<'t>,
  ~cancelledFn: cancelledFn=() => Console.info("future was cancelled"),
) =>
  future.value()->Promise.thenResolve(t => {
    switch t {
    | Ok(t) => successFn(t)
    | Error(e) => errorFn(e)
    | Cancelled => cancelledFn()
    }
  })

let cancel = t => t := true

let t1 = ref(false)

let fn = () =>
  make(() => Webapi.Fetch.fetch("http://httpstat.us/200?sleep=100"), ~cancelled=t1)
  ->map(res => {
    res
  })
  ->fold(Console.log, Console.log)

let _ = fn()
let _ = cancel(t1)

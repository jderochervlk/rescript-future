@send
external safeCatch: (promise<'a>, 'e => result<'a, 'e>) => 'e = "catch"

type future<'a, 'e> = unit => promise<result<'a, 'e>>

let make = (lazyPromise: unit => promise<'a>): future<'a, 'e> => () => {
  try {
    lazyPromise()
  } catch {
  | e => Promise.make((_, rej) => rej(e))
  }
  ->Promise.thenResolve(t => Ok(t))
  ->safeCatch(e => Error(e))
}

let map = (future: future<'a, 'e>, fn: 'a => 'b): future<'b, 'e> => () =>
  future()->Promise.thenResolve(t =>
    switch t {
    | Ok(t) => Ok(fn(t))
    | Error(e) => Error(e)
    }
  )

let mapError = (future: future<'a, 'e>, fn: 'e => 'b): future<'a, 'b> => () =>
  future()->Promise.thenResolve(t =>
    switch t {
    | Ok(t) => Ok(t)
    | Error(e) => Error(fn(e))
    }
  )

let mapPromise = (future: future<'a, 'e>, fn: 'a => promise<'b>): future<'d, 'g> => () =>
  future()->Promise.thenResolve(t =>
    switch t {
    | Ok(t) =>
      fn(t)
      ->Promise.thenResolve(t => Ok(t))
      ->safeCatch(e => Error(e))

    | Error(e) => Error(e)
    }
  )

let flatMap = (future: future<'a, 'e>, fn: 'a => result<'b, 'f>): future<'b, 'f> => () =>
  future()->Promise.thenResolve(t => {
    switch t {
    | Ok(t) => fn(t)
    | Error(e) => Error(e)
    }
  })

type successFn<'a, 'b> = 'a => 'b
type errorFn<'a, 'b> = 'a => 'b

let fold = (future: future<'a, 'e>, errorFn: errorFn<'f, 'g>, successFn: successFn<'t, 'u>) =>
  future()->Promise.thenResolve(t => {
    switch t {
    | Ok(t) => successFn(t)
    | Error(e) => errorFn(e)
    }
  })

let run = (future: future<'a, 'e>) => future()

let all2 = ((one: future<'a, 'e>, two: future<'b, 'f>)): future<
  ('a, 'b),
  (option<'g>, option<'h>),
> => {
  () =>
    Promise.all2((one(), two()))->Promise.thenResolve(t =>
      switch t {
      | (Ok(a), Ok(b)) => Ok((a, b))
      | (Error(a), Error(b)) => Error((Some(a), Some(b)))
      | (Error(a), _) => Error((Some(a), None))
      | (_, Error(b)) => Error((None, Some(b)))
      }
    )
}

let all3 = ((one: future<'a, 'e>, two: future<'b, 'f>, three: future<'c, 'g>)): future<
  ('a, 'b, 'c),
  (option<'g>, option<'h>, option<'i>),
> => {
  () =>
    Promise.all3((one(), two(), three()))->Promise.thenResolve(t =>
      switch t {
      | (Ok(a), Ok(b), Ok(c)) => Ok((a, b, c))
      | (Error(a), Error(b), Error(c)) => Error((Some(a), Some(b), Some(c)))
      | (Error(a), _, _) => Error((Some(a), None, None))
      | (_, Error(b), _) => Error((None, Some(b), None))
      | (_, _, Error(c)) => Error((None, None, Some(c)))
      }
    )
}

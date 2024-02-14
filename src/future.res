@send
external safeCatch: (promise<'a>, 'e => result<'a, 'e>) => 'e = "catch"

type result<'a, 'e> =
  | Ok('a)
  | Error('e)
  | Cancelled

type future<'a, 'e> = {
  value: unit => promise<result<'a, 'e>>,
  cancelled: ref<bool>,
  controller: option<Webapi.Fetch.AbortController.t>,
}

let make = (lazyPromise: unit => promise<'a>, ~controller=?): future<'a, 'e> => {
  let cancelled = ref(false)
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
    controller,
  }
}

let map = (future: future<'a, 'e>, fn: 'a => 'b): future<'b, 'e> => {
  value: () =>
    future.value()->Promise.thenResolve(t =>
      switch t {
      | Ok(t) => future.cancelled.contents === true ? Cancelled : Ok(fn(t))
      | Error(e) => future.cancelled.contents === true ? Cancelled : Error(e)
      | Cancelled => Cancelled
      }
    ),
  cancelled: future.cancelled,
  controller: future.controller,
}

let mapError = (future: future<'a, 'e>, fn: 'e => 'b): future<'a, 'b> => {
  value: () =>
    future.value()->Promise.thenResolve(t =>
      switch t {
      | Ok(t) => future.cancelled.contents === true ? Cancelled : Ok(t)
      | Error(e) => future.cancelled.contents === true ? Cancelled : Error(fn(e))
      | Cancelled => Cancelled
      }
    ),
  cancelled: future.cancelled,
  controller: future.controller,
}

let mapPromise = (future: future<'a, 'e>, fn: 'a => promise<'b>): future<'d, 'g> => {
  value: () =>
    future.value()->Promise.thenResolve(t =>
      switch t {
      | Ok(t) =>
        fn(t)
        ->Promise.thenResolve(t => future.cancelled.contents === true ? Cancelled : Ok(t))
        ->safeCatch(e => Error(e))

      | Error(e) => future.cancelled.contents === true ? Cancelled : Error(e)
      | Cancelled => Cancelled
      }
    ),
  cancelled: future.cancelled,
  controller: future.controller,
}

let flatMap = (future: future<'a, 'e>, fn: 'a => result<'b, 'f>): future<'b, 'f> => {
  value: () =>
    future.value()->Promise.thenResolve(t => {
      switch t {
      | Ok(t) => future.cancelled.contents === true ? Cancelled : fn(t)
      | Error(e) => future.cancelled.contents === true ? Cancelled : Error(e)
      | Cancelled => Cancelled
      }
    }),
  cancelled: future.cancelled,
  controller: future.controller,
}

type successFn<'a> = 'a => unit
type errorFn<'a> = 'a => unit

let fold = (future: future<'a, 'e>, errorFn: errorFn<'f>, successFn: successFn<'t>) =>
  future.value()->Promise.thenResolve(t => {
    switch t {
    | Ok(t) => successFn(t)
    | Error(e) => errorFn(e)
    | Cancelled => ()
    }
  })

let run = (future: future<'a, 'e>) => future.value()

let cancel = (future: future<'a, 'e>) => {
  future.controller->Option.forEach(Webapi.Fetch.AbortController.abort)
  future.cancelled := true
}

let all2 = ((one: future<'a, 'e>, two: future<'b, 'f>)): future<
  ('a, 'b),
  (option<'g>, option<'h>),
> => {
  {
    value: () =>
      Promise.all2((one.value(), two.value()))->Promise.thenResolve(t =>
        switch t {
        | (Ok(a), Ok(b)) => Ok((a, b))
        | (Error(a), Error(b)) => Error((Some(a), Some(b)))
        | (Error(a), _) => Error((Some(a), None))
        | (_, Error(b)) => Error((None, Some(b)))
        | (Cancelled, _) => Cancelled
        | (_, Cancelled) => Cancelled
        }
      ),
    cancelled: one.cancelled,
    controller: one.controller,
  }
}

let all3 = ((one: future<'a, 'e>, two: future<'b, 'f>, three: future<'c, 'g>)): future<
  ('a, 'b, 'c),
  (option<'g>, option<'h>, option<'i>),
> => {
  value: () =>
    Promise.all3((one.value(), two.value(), three.value()))->Promise.thenResolve(t =>
      switch t {
      | (Ok(a), Ok(b), Ok(c)) => Ok((a, b, c))
      | (Error(a), Error(b), Error(c)) => Error((Some(a), Some(b), Some(c)))
      | (Error(a), _, _) => Error((Some(a), None, None))
      | (_, Error(b), _) => Error((None, Some(b), None))
      | (_, _, Error(c)) => Error((None, None, Some(c)))
      | (Cancelled, _, _) => Cancelled
      | (_, Cancelled, _) => Cancelled
      | (_, _, Cancelled) => Cancelled
      }
    ),
  cancelled: one.cancelled,
  controller: one.controller,
}

let fetch = string => {
  let controller = Webapi.Fetch.AbortController.make()
  let init = Webapi.Fetch.RequestInit.make(~signal=controller.signal, ())
  make(() => Webapi.Fetch.fetchWithInit(string, init), ~controller)
}

let fetchWithInit = (string, init: Webapi.Fetch.RequestInit.t, controller) => {
  make(() => Webapi.Fetch.fetchWithInit(string, init), ~controller)
}

let fetchWithRequest = request => {
  let controller = Webapi.Fetch.AbortController.make()
  let init = Webapi.Fetch.RequestInit.make(~signal=controller.signal, ())
  make(() => Webapi.Fetch.fetchWithRequestInit(request, init), ~controller)
}

let fetchWithRequestInit = (request, init: Webapi.Fetch.RequestInit.t, controller) => {
  make(() => Webapi.Fetch.fetchWithRequestInit(request, init), ~controller)
}

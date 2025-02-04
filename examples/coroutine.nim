
import cps, options, deques

type
  Coroutine = ref object of Continuation
    s: int
    cResume: Coroutine


proc tramp(c: Coroutine): Coroutine {.discardable.}  =
  var c = Continuation: c
  while c.running:
    c = c.fn(c)
  result = Coroutine: c

proc recv(c: Coroutine): int {.cpsVoodoo.} =
  c.s

proc jield(c: Coroutine): Coroutine {.cpsMagic.} =
  c.cResume = c

proc send(c: Coroutine, s: int) =
  c.s = s
  tramp c.cResume

# This coroutine doubles numbers

proc fn_coro1(dest: Coroutine, dummy: bool) {.cps:Coroutine.} =
  while true:
    jield()
    let v = recv()
    dest.send(v * 2)

# This coro receives ints from coro1 and prints them

proc fn_coro2() {.cps:Coroutine.} =
  while true:
    jield()
    let val = recv()
    echo val


let coro2 = whelp fn_coro2()
let coro1 = whelp fn_coro1(coro2, true)

coro1.tramp()
coro2.tramp()

for i in 1..10:
  coro1.send(i)

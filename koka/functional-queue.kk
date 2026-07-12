import std/num/int64

type qlist
  QNil
  QCons(value : int64, rest : qlist)

type rotation
  Idle
  Reversing(ok : int, front : qlist, front-rev : qlist, rear : qlist, rear-rev : qlist)
  Appending(ok : int, front-rev : qlist, rear-rev : qlist)
  Done(front : qlist)

struct queue(
  len-front : int,
  front : qlist,
  state : rotation,
  len-rear : int,
  rear : qlist
)

fun exec( state : rotation ) : rotation
  match state
    Reversing(ok,QCons(x,f),f1,QCons(y,r),r1) ->
      Reversing(ok + 1,f,QCons(x,f1),r,QCons(y,r1))
    Reversing(ok,QNil,f1,QCons(y,QNil),r1) -> Appending(ok,f1,QCons(y,r1))
    Appending(0,_,r1) -> Done(r1)
    Appending(ok,QCons(x,f1),r1) -> Appending(ok - 1,f1,QCons(x,r1))
    _ -> state

fun invalidate( state : rotation ) : rotation
  match state
    Reversing(ok,f,f1,r,r1) -> Reversing(ok - 1,f,f1,r,r1)
    Appending(0,_,QCons(_,r1)) -> Done(r1)
    Appending(ok,f1,r1) -> Appending(ok - 1,f1,r1)
    _ -> state

fun exec2( q : queue ) : queue
  match exec(exec(q.state))
    Done(front) -> Queue(q.len-front,front,Idle,q.len-rear,q.rear)
    state -> Queue(q.len-front,q.front,state,q.len-rear,q.rear)

fun check( q : queue ) : queue
  if q.len-rear <= q.len-front then exec2(q) else
    exec2(Queue(q.len-front + q.len-rear,q.front,
                Reversing(0,q.front,QNil,q.rear,QNil),0,QNil))

fun snoc( q : queue, value : int64 ) : queue
  check(Queue(q.len-front,q.front,q.state,q.len-rear + 1,QCons(value,q.rear)))

fun uncons( q : queue ) : (int64,queue)
  match q.front
    QCons(value,front) ->
      (value,check(Queue(q.len-front - 1,front,invalidate(q.state),q.len-rear,q.rear)))
    QNil -> (0.int64,q)

val modulus = 1000000007.int64

fun build( index : int, q : queue ) : div queue
  if index == 65536 then q else build(index + 1,snoc(q,index.int64))

fun churn( round : int64, remaining : int, q : queue, checksum : int64 ) : div (queue,int64)
  if remaining == 0 then (q,checksum) else
    val (value,rest) = uncons(q)
    val next = (value + round + 1.int64) % modulus
    churn(round + 1.int64,remaining - 1,snoc(rest,next),(checksum + value) % modulus)

fun drain( remaining : int, q : queue, checksum : int64 ) : div int64
  if remaining == 0 then checksum else
    val (value,rest) = uncons(q)
    drain(remaining - 1,rest,(checksum + value) % modulus)

pub fun main()
  val (q,checksum) = churn(0.int64,1000000,build(0,Queue(0,QNil,Idle,0,QNil)),0.int64)
  val result = drain(65536,q,checksum)
  if result != 66797929.int64 then
    println("FAIL: expected 66797929, got " ++ result.show)
    throw("wrong result")

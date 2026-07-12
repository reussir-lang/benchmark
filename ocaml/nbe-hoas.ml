type term =
  | Var of int
  | Lam of int * term
  | App of term * term
  | Let of int * term * term

type value =
  | VVar of int
  | VApp of value * value
  | VLam of int * (value -> value)

type env = Cons of int * value * env | Nil

let rec max_of_names names acc =
  match names with
  | id :: rest -> max_of_names rest (max acc id)
  | [] -> acc

let rec names_of_env env acc =
  match env with Cons (id, _, rest) -> names_of_env rest (id :: acc) | Nil -> acc

let fresh names = max_of_names names 0 + 1

let rec lookup env id =
  match env with
  | Cons (id1, value, rest) -> if id = id1 then value else lookup rest id
  | Nil -> VVar id

let rec eval env = function
  | Var id -> lookup env id
  | App (t, u) -> vapp (eval env t) (eval env u)
  | Lam (id, body) -> VLam (id, fun value -> eval (Cons (id, value, env)) body)
  | Let (id, t, u) -> eval (Cons (id, eval env t, env)) u

and vapp v1 v2 = match v1 with VLam (_, body) -> body v2 | _ -> VApp (v1, v2)

let rec quote names = function
  | VVar id -> Var id
  | VApp (v1, v2) -> App (quote names v1, quote names v2)
  | VLam (_, body) ->
      let y = fresh names in
      Lam (y, quote (y :: names) (body (VVar y)))

let norm_form env term = quote (names_of_env env []) (eval env term)

let lam id body = Lam (id, body)
let app f x = App (f, x)

let five =
  lam 0 (lam 1 (app (Var 0) (app (Var 0) (app (Var 0) (app (Var 0) (app (Var 0) (Var 1)))))))

let add =
  lam 0 (lam 1 (lam 2 (lam 3 (app (app (Var 0) (Var 2)) (app (app (Var 1) (Var 2)) (Var 3))))))

let mul =
  lam 0 (lam 1 (lam 2 (lam 3 (app (app (Var 0) (app (Var 1) (Var 2))) (Var 3)))))

let ten = App (App (add, five), five)
let twenty = App (App (add, ten), ten)
let hundred = App (App (mul, ten), ten)
let two_hundred = App (App (add, hundred), hundred)
let thousand = App (App (mul, hundred), ten)
let term_200000 = App (App (mul, two_hundred), thousand)
let term_1000000 = App (App (mul, five), term_200000)

let rec nf_to_int term acc =
  match term with
  | Lam (_, body) -> nf_to_int body acc
  | App (_, body) -> nf_to_int body (acc + 1)
  | _ -> acc

let nbe_test seed = nf_to_int (norm_form Nil term_1000000) seed

let () =
  let rec rounds i acc = if i = 6 then acc else rounds (i + 1) (acc + nbe_test i) in
  let result = rounds 0 0 in
  if result <> 6_000_015 then (
    Printf.eprintf "FAIL: expected 6000015, got %d\n" result;
    exit 1)

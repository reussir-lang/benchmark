{-# LANGUAGE BangPatterns #-}

module Main where

data Term
  = Var !Int
  | Lam !Int !Term
  | App !Term !Term
  | Let !Int !Term !Term

data Value
  = VVar !Int
  | VApp !Value !Value
  | VLam !Int (Value -> Value)

data Env
  = Cons !Int !Value !Env
  | Nil

data Names
  = NameCons !Int !Names
  | NameNil

maxOfNames :: Names -> Int -> Int
maxOfNames names !acc =
  case names of
    NameCons ident rest -> maxOfNames rest (if acc > ident then acc else ident)
    NameNil -> acc

namesOfEnv :: Env -> Names -> Names
namesOfEnv env acc =
  case env of
    Cons ident _ env1 -> namesOfEnv env1 (NameCons ident acc)
    Nil -> acc

fresh :: Names -> Int
fresh n = maxOfNames n 0 + 1

lookupEnv :: Env -> Int -> Value
lookupEnv env ident =
  case env of
    Cons ident1 val env1 ->
      if ident == ident1
        then val
        else lookupEnv env1 ident
    Nil -> VVar ident

eval :: Env -> Term -> Value
eval env term =
  case term of
    Var ident -> lookupEnv env ident
    App t u -> vapp (eval env t) (eval env u)
    Lam xId t ->
      VLam xId (\u -> eval (Cons xId u env) t)
    Let xId t u ->
      let v = eval env t
       in eval (Cons xId v env) u

vapp :: Value -> Value -> Value
vapp v1 v2 =
  case v1 of
    VLam _ body -> body v2
    _ -> VApp v1 v2

quoteValue :: Names -> Value -> Term
quoteValue n v =
  case v of
    VVar ident -> Var ident
    VApp v1 v2 -> App (quoteValue n v1) (quoteValue n v2)
    VLam _ f ->
      let y = fresh n
          n2 = NameCons y n
       in Lam y (quoteValue n2 (f (VVar y)))

normForm :: Env -> Term -> Term
normForm env t =
  let names = namesOfEnv env NameNil
      v = eval env t
   in quoteValue names v

five :: Term
five =
  Lam
    0
    ( Lam
        1
        ( App
            (Var 0)
            ( App
                (Var 0)
                ( App
                    (Var 0)
                    (App (Var 0) (App (Var 0) (Var 1)))
                )
            )
        )
    )

add :: Term
add =
  Lam
    0
    ( Lam
        1
        ( Lam
            2
            ( Lam
                3
                ( App
                    (App (Var 0) (Var 2))
                    (App (App (Var 1) (Var 2)) (Var 3))
                )
            )
        )
    )

mul :: Term
mul =
  Lam
    0
    ( Lam
        1
        ( Lam
            2
            ( Lam
                3
                ( App
                    (App (Var 0) (App (Var 1) (Var 2)))
                    (Var 3)
                )
            )
        )
    )

ten :: Term
ten = App (App add five) five

twenty :: Term
twenty = App (App add ten) ten

hundred :: Term
hundred = App (App mul ten) ten

twoHundred :: Term
twoHundred = App (App add hundred) hundred

thousand :: Term
thousand = App (App mul hundred) ten

term200000 :: Term
term200000 = App (App mul twoHundred) thousand

term4000000 :: Term
term4000000 = App (App mul twenty) term200000

nfToInt :: Term -> Int -> Int
nfToInt t !acc =
  case t of
    Lam _ x -> nfToInt x acc
    App _ x -> nfToInt x (acc + 1)
    _ -> acc

nbeTest :: Int
nbeTest =
  let n = normForm Nil term4000000
   in nfToInt n 0

main :: IO ()
main = do
  let n = nbeTest
  if n /= 4000000
    then error ("FAIL: expected 4000000, got " ++ show n)
    else pure ()

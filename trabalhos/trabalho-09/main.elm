import Html exposing (text)

type alias Env = (String -> Int)
zero : Env
zero = \ask -> 0

type Exp = Add Exp Exp
         | Num Int
         | Var String


e1 : Exp
e1 = Add (Num 9) (Num 1)

evalExp : Exp -> Env -> Int
evalExp exp env =   
    case exp of
        Add exp1 exp2  -> (evalExp exp1 env) + (evalExp exp2 env)
        Num v          -> v
        Var var        -> (env var)

type Prog = Attr String Exp
          | Seq Prog Prog
          | If Exp Prog Prog
          | While Exp Prog Prog

evalProg : Prog -> Env -> Env
evalProg s env =
    case s of
        Seq s1 s2 ->
            (evalProg s2 (evalProg s1 env))
        Attr var exp ->
            let
                val = (evalExp exp env)
            in
                \ask -> if ask==var then val else (env ask)
        If exp progTrue progFalse -> 
            evalProg (if (evalExp exp env > 0) then progTrue else progFalse) env
        While exp progWhile progBreak -> 
            if (evalExp exp env < 11) then evalProg (While exp progWhile progBreak) (evalProg progWhile env) else evalProg progBreak env


lang : Prog -> Int
lang p = ((evalProg p zero) "ret")

p1 : Prog
p1 = (Attr "ret" (Add (Num 11) (Num 9)))

p2 : Prog
p2 = Seq
        (Attr "x" (Num 11))
        (Attr "ret" (Add (Var "x") (Num 9)))

p3 : Prog
p3 = If (Num 0)
        (Attr "ret"   (Num 11))
        (Attr "ret" (Add (Num 5) (Num 9)))

p4 : Prog
p4 = Seq 
        (Attr "y" (Num 2))
        (While (Var "y")
            (Attr "y" (Add (Var "y") (Num 2)))
            (Attr "ret" (Var "y"))
        )

--main = text (toString (lang p1))
main = text (toString (lang p4))

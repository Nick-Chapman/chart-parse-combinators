open Core.Std
open Chart.Rule

let number_of_parses = Chart.Res.(function  
  | Succ _ -> Some 1
  | Amb (`number_parses n,_) -> Some n
  | Fail _ -> None)

type nt = S | Q | Word of string

type 'a rule = (nt,'a) Chart.Rule.t

let x : unit rule = select (function Word _ -> Some () | _ -> None)
let q : unit rule = select (function Q -> Some () | _ -> None)
    
let gram : nt rule = alt [
  (q -$$ q -$$ q -$$ q -$$ q -$$ q -$$ q -$$ return S);
  (x -$$ return Q); 
  (return Q); (* Q is nullable *)
]

let dict : string -> nt list = fun word -> [Word word]

let accept : nt -> unit option = function
  | S -> Some ()
  | _ -> None

let run words = Chart.parse ~dict ~gram ~accept ~words ()

let test s =
  let words = List.map (String.to_list s) ~f:(String.make 1) in
  printf "words: %s\n" (String.concat ~sep:" " words);
  printf !"res: %{sexp:int option}\n" (number_of_parses (run words))

let%expect_test _ =
  test "123"; (* choose 3 from 7 *)
  [%expect {|
      words: 1 2 3
      res: (35)|}]

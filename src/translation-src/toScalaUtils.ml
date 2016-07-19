open Struct;;

(* The function to translate the solution modifiers. *)
let modifiers () = ".collect;\n";;



(* The idea of 'adjust' is to provide a modified 'l1' where duplicates with 'l2' are a bit changed
   e.g. l1=[a;b;c] l2=[a;x;y] adjust(l1,l2)=[a1;b;c] *)
let adjust (l1:string list) (l2:string list):string list =
  let rec aux l1 l2 lresult = match l1 with
  | [] -> List.rev lresult
  | t :: q -> if List.mem t l2 = true
    then aux q l2 ((t^"bis") :: lresult) (* Obviously, a problem can occured if a variable has been named ?xbis also... *)
    else aux q l2 (t :: lresult)
  in aux l1 l2 []
;;

let printlist(l:string list):string = 
  let rec aux(l) = match l with
  | [] -> ""
  | [t] -> t
  | t :: q -> t^","^aux(q)
  in "("^aux(l)^")"
;;

let union((l1:string list),(l2:string list)):string list=
  let rec deleteDuplicate ll = (* A stupid version. *)
    match ll with 
    | [] -> []
    | x :: [] -> x :: [] 
    | x :: y :: rest -> 
      if compare x y = 0
      then deleteDuplicate (y :: rest) 
      else x :: deleteDuplicate (y :: rest) 
  in
  let l1sort = List.sort compare l1 in
  let l2sort = List.sort compare l2 in
  deleteDuplicate(List.merge compare l1sort l2sort)
;;




let return_biggest_label(env:environment):int=
  let rec aux l result = match l with
    | [] -> result.label
    | t :: q -> if (List.length t.varlist) >= (List.length result.varlist)
      then aux q t
      else aux q result
  in let initial:element={var="";label=0;nbJoin=0;varlist=[]} in
     aux env.suite initial
;;


let contained l1 l2 = (* We assuming that there are no duplicate values in l1 and l2 *)
  let rec aux l1 l2 n = match l1 with
    | [] -> n
    | t :: q -> if List.mem t l2 = true
      then aux q l2 (n+1)
      else aux q l2 n
  in if List.length l1 = aux l1 l2 0
    then true
    else false
;;

(* Return the element that having a varlist containing dist and having the biggest label *)
let return_good((dist:string list) , (env:environment) ):element =
  let rec aux d e el = match e with
    | [] -> el
    | t::q -> if contained d t.varlist = true
      then begin
	if el.label <= t.label
	then aux d q t
	else aux d q el
      end else
	aux d q el
  in let initial:element={var="";label=0;nbJoin=0;varlist=[]} in
     aux dist env.suite initial
;;

(* The function to translate the distingushed variables. *)
let select ( (dist:atom list) , (env:environment) ) =
  if List.hd dist = Exact("*")
  then
    let good_label:int = return_biggest_label(env) in
    "Q"^string_of_int(good_label)
  else
    let string_dist = List.map atom2string dist in
    let good_element:element = return_good(string_dist,env) in
    "Q"^string_of_int(good_element.label)^".map{case "^(printlist good_element.varlist)^"=>"^(printlist(string_dist))^"}"
;;
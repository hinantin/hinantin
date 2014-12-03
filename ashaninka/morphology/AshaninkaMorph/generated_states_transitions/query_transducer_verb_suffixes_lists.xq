declare namespace xs = "http://www.w3.org/2001/XMLSchema";
declare variable $file_name external; 
(:declare variable $file_name  := 'annotated_sentences_wtg.xml';:)

fn:distinct-values(
for $word in doc($file_name)//sentences//sentence//words//word
  where $word[matches(@type,'verb')]
  return
  fn:concat(
    fn:string-join(
    (for $element in $word//elements//element
    let $e_asl := $element//e_asl//text()
    let $result := fn:concat('(V=S=',fn:replace($e_asl,'\.',''), ') ')
    return
      if ($element//e_asl[fn:matches(text(),'\.A$')] or $element//e_asl[fn:matches(text(),'\.S$')]) 
      then ()
      else if ($element//e_asl[fn:matches(text(),'.O')])
      then '(V=S=PRNO) '
      else if ($element//e_asl[fn:matches(text(),'^EP$')])
      then ()
      else if ($element//e_asl[fn:matches(text(),'^CL:')])
      then '(V=S=CL) '
      else if ($element[fn:matches(@sign,'isroot:yes')])
      then ()
      else $result
    )
    )
  , "| &#10;")
)
 (:
  return fn:concat(fn:string-join($word//elements//element//e_asl//text(), " "), "&#10;")
    fn:concat(
    (for $element in $word//elements//element
    let $e_asl := $element//e_asl//text()
    let $result := fn:concat('(',$e_asl, ') ')
    return fn:string-join($result, " "))
    ,"&#10;")
    
    :) 
declare function local:get-orderedlist($category,$left)
      as xs:string {
   for $x at $pos in $category 
   return concat(string($pos),'  ',$left[$pos],'')
};

for $entry in doc("/home/richard/Descargas/RCastroq/dropbox/Dropbox/05_Ashaninca/01_Diccionarios_Bilingues/CNI_ENG__ENG_CNI/preliminar_dictionary_cni_eng.xml")//e
let $right := $entry//r 
let $left := distinct-values($entry//l)
let $category := string-join(data($entry//r//s/@n),', ')
let $category := local:get-orderedlist($category,$right)
group by $left
order by $left ascending
return concat($left,"&#9;",string-join($category,"; "),". &#xa;")

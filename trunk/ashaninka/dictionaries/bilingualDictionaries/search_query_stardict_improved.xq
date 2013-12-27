declare function local:get-orderedlist($category,$left)
      as xs:string {
   for $x at $pos in $category 
   return concat(string($pos),'. (',string($x), ')  ',$left[$pos],'')
};

for $entry in doc("/home/richard/Descargas/RCastroq/dropbox/Dropbox/05_Ashaninca/01_Diccionarios_Bilingues/CNI_ESP__ESP_CNI/DiccionarioCastellanoAshaninka.xml")//e
let $right := distinct-values($entry//r) 
let $left := $entry//l
let $category := string-join(data($entry//r//s/@n),', ')
let $category := local:get-orderedlist($category,$left)
group by $right
order by $right ascending
return concat($right,"&#9;",string-join($category,"; "),". &#xa;")

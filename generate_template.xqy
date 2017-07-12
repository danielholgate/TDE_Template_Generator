xquery version "1.0-ml";

module namespace tg = 'templateGenerator';
import module namespace functx = 'http://www.functx.com' at '/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy';

(: determines common TDE datatype for values in a sequence :)
declare function tg:determineType ( $values as xs:anyAtomicType* ) as xs:string* {

 let $types := for $val in $values
 return if ($val castable as xs:boolean) then 'boolean'
 else if ($val castable as xs:long) then 'long'
 else if ($val castable as xs:integer) then 'integer'
 else if ($val castable as xs:float) then 'float'
 else if ($val castable as xs:date) then 'date'
 else if ($val castable as xs:dateTime) then 'dateTime'
 else if ($val castable as xs:string) then 'string'
 else 'unknown'
 let $distinctTypes := fn:distinct-values($types)
 (: String is lowest common denominator datatype - Use if no other data type fits all values :)
 let $returnType := if ( functx:is-value-in-sequence('string',$distinctTypes) ) then 'string' else $distinctTypes[1]
 return $returnType
 };
 
(: Function to generate templates for TDE. Inputs: Schema Name, View Name, and document to build template from :) 
declare function tg:generateTemplate($schema as xs:string, $viewName as xs:string, $doc as node())
as item()* {

let $sampleSize := 100
let $from :=	('-','\.','__')
let $to:=	('_','_','_')

let $docURI := fn:document-uri($doc)

let $columns := for $e in $doc/*/*
  let $elementpath := xdmp:path($e,fn:false())
  let $elementName := fn:tokenize($elementpath,'/')[last()]
  (: Replace any hyphens or dots/periods in column names with _ :) 
  let $templateColumnName := functx:replace-multi($elementName,$from,$to)
  
  (: Sample 100 elements at this path and determine data type :)
  let $dataSample := xdmp:unpath($elementpath)[1 to $sampleSize]/data()
  let $nullable := functx:is-value-in-sequence('',$dataSample)
  let $dataType := tg:determineType($dataSample)
return
<column xmlns='http://marklogic.com/xdmp/tde'>
  <name>{$templateColumnName}</name>
  <scalar-type>{$dataType}</scalar-type>
  <val>{$elementName}</val> 
  { if ( $nullable ) then <nullable>true</nullable> else ()}
</column>

let $col := <columns xmlns='http://marklogic.com/xdmp/tde'>{$columns}</columns>

let $template := 
                    <template xmlns='http://marklogic.com/xdmp/tde'>
                      <description>Autogenerated template from {$docURI}</description>
                      <!-- <collections><collection>someCollection</collection></collections> -->
                      <!-- <directories><directory>/some/directory/</directories>-->
                      <context>{xdmp:path($doc/*)}</context>
                      <rows>
                        <row>
                          <schema-name>{$schema}</schema-name>
                          <view-name>{$viewName}</view-name>
                          {$col}
                         </row>
                        </rows>
                      </template>

return $template
};
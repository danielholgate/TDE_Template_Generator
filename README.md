# TDE Template Generator
This is an XQuery module for MarkLogic to "auto generate" templates for [Template Driven Extraction (TDE)](https://docs.marklogic.com/guide/sql/creating-template-views#id_81078)

Use case is when you have an existing set of documents and want to avoid the work of inspecting data types and the typing/copy & pasting needed to build out the template needed for serving out as SQL using TDE. Generated templates can then be manually adjusted as needed.

To generate a template, first choose a sample XML document which is representative of those you want to create a template for.
Supply the URI to the tg:generateTemplate function along with the schema name and the table name.

The template generator will:
* Build a <column> element for each immediate child of the root element (hence best for MLCP-loaded CSV data, or simple XML document datasets) 
* Sample 100 element values from each element (xpath) path to best guess the correct data type for each column.
* Test if any empty (= 0 byte length) values exist in the 100 values at the path and if so set the column as NULLABLE
* Use the original element name as the column name, but replace . or - (not allowed for TDE column names) with _
* Generate the final template

# Installation
Save generate_template.xqy to a path accessible by MarkLogic and load the module from the filesystem with the following in a Query Console tab:
```
(xdmp:document-load("/path/to/template_generator.xqy",
    <options xmlns="xdmp:document-load">
      <uri>/tde/tde_template_generator.xqy</uri>
      <repair>none</repair>
      <permissions>{xdmp:default-permissions()}</permissions>
</options>),"Module loaded")
```
# Usage
Include the template generator library by importing it with:
```
import module namespace tg="templateGenerator" at "/tde/tde_template_generator.xqy";
```
Choose an XML document which represents the document set you want to build a template for and use:
```
tg:generateTemplate(<name of your schema>,<name of your table>, $doc)
```
This will generate an XML template document which can be used in the MarkLogic [tde:template-insert](https://docs.marklogic.com/tde:template-insert) function.

## Usage example
You've loaded a CSV dataset of consumer complaints data through MLCP and from them chosen document "/load/data/complaints_small.csv-0-10" as a sample to build a TDE template from. The table will be "complaints" in schema "GovData"
```
 let $doc := doc("/load/data/complaints_small.csv-0-10")
 let $template := tg:generateTemplate("GovData", "complaints", $doc)
 return ($template,tde:validate($template))
 ```
This will return the template and show the results of validation. If you're happy with the template, use the following to create and save it in MarkLogic:

``` 
let $doc := doc("/load/data/complaints_small.csv-0-10")
let $template := tg:generateTemplate("GovData", "complaints", $doc)
return  tde:template-insert("/Template-complaints.xml", $template)
```

### SQL Access  
In a SQL tab in Query Console now run:
``` 
select * from GovData.complaints
``` 



### TODO
* Better data type testing
* Build template from more complex XML sample documents

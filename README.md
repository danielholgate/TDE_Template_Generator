# TDE Template Generator
This is an XQuery module for MarkLogic to "auto generate" templates for Template Driven Extraction (TDE)

The use case is being able to perform the currently manual work of inspecting data and typing/copy & pasting when building the templates needed for serve the data out as SQL using TDE. Generated templates can then be manually adjusted as needed.

To generate a template, first choose a sample XML document which is representative of those you want to create a template for.
Supply the URI to the tg:generateTemplate function along with the schema name and the table name.

The template generator will:
* Build a column for each immediate child of the root element (hence best for MLCP-loaded CSV data, or simple XML document datasets) 
* Sample 100 values from that element path to determine the correct data type for each columns
* Test if any empty (= 0 byte length) values exist from the 100 values at the path and if so set the column as NULLABLE
* Generate the final template and validate

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

# TDE_Template_Generator
This is an XQuery module for MarkLogic to "auto generate" templates for Template Driven Extraction (TDE)

The use case is primarily loading CSV data sets and then being able to quickly serve the data out as SQL using TDE with minimal effort. Templates can then be manually adjusted as needed.

To generate a template, first choose a sample XML document which is representative of those you want to create a template for.
Supply the URI to the tg:generateTemplate function along with the schema name and the table name.

The template generator will:
* Build a column for each immediate child of the root element (hence best for MLCP-loaded CSV data, or simple XML datasets) 
* Sample 100 element values for all values at that element path to determine datatype for the columns
* Test if empty values exist and if so set the column as NULLABLE
* Generate the final template and validate

# Installation
Save template_generator.xqy to a path accessivle by MarkLogic and load the module from the filesystem with:
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
Choose a XML document which represents the documents you want to build a template for and run
```
tg:generateTemplate("GovDataSchema", "complaints", $doc)
```

You've loaded a CSV dataset through MLCP and chosen document /space/software/TDE/complaints_small.csv-0-10 to build a template:
```
 let $doc := doc("/space/software/TDE/complaints_small.csv-0-10")
 let $template := tg:generateTemplate("GovDataSchema", "complaints", $doc)
 return ($template,tde:validate($template))
 ```
When you're happy with the template, use the following to create and save it in MarkLogic:

``` 
let $doc := doc("/space/software/TDE/complaints_small.csv-0-10")
let $template := tg:generateTemplate("GovDataSchema", "complaints", $doc)
return  tde:template-insert("/Template-complaints.xml", $template)
```

**In a SQL tab in Query console run:

select * from GovDataSchema.complaints

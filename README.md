# TDE_Template_Generator
Auto generates templates for MarkLogic Template Driven Extraction (TDE)

This is an XQuery module for MarkLogic to generate templates for Template Driven Extraction (TDE)

The use case for using this is primarily loading CSV datasets and then being able to quickly serve the data out as SQL using TDE.

To generate a template, first choose a sample document which is representative of the documents you want to create a template for and supply the URI to the generateTemplate function along with the schema name and the table name.

The template generator will:
Iterate each immediate child of the root element (hence best for MLCP-loaded CSV data, or simple XML datasets) 
Select the common datatype for all values at that element path
Test if any empty values exist and set the column as NULLABLE if there are
Create the template and validate

Example
(: TEST THE TEMPLATE GENERATOR :)

 let $doc := doc("/space/software/TDE/complaints_small.csv-0-10")
 let $template := local:generateTemplate("GovDataSchema", "complaints", $doc)
 return ($template,tde:validate($template))
 
 (: When you are happy with the template above, use the following to create it :)
 
let $doc := doc("/space/software/TDE/complaints_small.csv-0-10")
let $template := local:generateTemplate("GovDataSchema", "complaints", $doc)
return  tde:template-insert("/Template-complaints.xml", $template)

**In a SQL table in Query console run:

select * from GovDataSchema.complaints

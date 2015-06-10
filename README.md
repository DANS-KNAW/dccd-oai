DCCD OAI-MPH
============

This document describes dccd-oai; a service that provides a RESTfull interface to the DCCD archive and thus exposes machine readable information. The dccd-oai is a service that implements a OAI-MPH interface for harvesting DCCD 'projects'. 

This is an open publicly availabe interface for harversting the archive. 
Only archived (published) projects (datasets) should be available. 
The information from the dccd-rest service is being used as input, so we specify here from what dccd-rest output it is constructed. 

For OAI-MPH see: http://www.openarchives.org/OAI/openarchivesprotocol.html
[http://www.openarchives.org/OAI/openarchivesprotocol.html](http://www.openarchives.org/OAI/openarchivesprotocol.html)

Installation
------------
You need to build it from the source code. 
Change the configuration and possibly some other files in the src/main/resources folder. 

Properties in the proai.properties file specific for DCCD are:

	proai.driverClassName
	driver.dccd.rest.url

Setup the proai database, the default config uses Postgres with database proia and user proai. 

	$ psql -U postgres
	CREATE ROLE "proai" LOGIN PASSWORD 'proai';
	CREATE DATABASE "proai" WITH ENCODING='UTF8' OWNER="###Fill-In-proai-Password###";

You need to set the passwords in the properties file for both proai and fedoraAdmin:  
In src/main/resources/proai.properties, look for 
###Fill-In-fedoraAdmin-Password### 
and 
###Fill-In-proai-Password###


For details on proai see: [http://proai.sourceforge.net/](http://proai.sourceforge.net/)

After building deploy the war on the server. The proai service will retrieve the 'public' data for all archived projects, which may take a while. When it is done with this initialisation you could check if it 'follows' the archive by archiving a new project. After a while it should be added to the OAI-MPH recordlist. 



Examples
--------
Assume that the service is deployed on the localhost at port 8080. 
You could use curl or just input the url in the browser to get the OAI XML results. 
 
Get OAI identification response
 
	$ curl "http://localhost:8080/dccd-oai/?verb=Identify"
	
 
Get a list of the projects
 
 	$ curl "http://localhost:8080/dccd-oai/?verb=ListRecords&metadataPrefix=oai_dc"


When the list is long you wil get only a part of all projecst and at the and of the response the is a resumption token. For instance: 

	<resumptionToken cursor="0">X1947676756/1</resumptionToken>
	
You can use that token to retrieve the next 'page' of results. But don't wai to long, otherwise the token is expired. 

	$ curl "http://localhost:8080/dccd-oai/?verb=ListRecords&resumptionToken=X1947676756/1
		

Formats
-------
Note that you can check the supported formats. 

	$ curl "http://localhost:8080/dccd-oai/?verb=ListMetadataFormats"


### oai_dc
Dublic core is very small and unstructured, so the orignal data is 'flattened' by the transformation. 

Transformation from the dccd-rest XML output is speciefied by the xsl file in: 
/dccd-oai/src/main/resources/dccd_to_oai_dc.xsl


fixed for all records (dccd projects):  

     <dc:subject>dendrochronology</dc:subject>
     <dc:description>Project</dc:description>
     <dc:type>name=TRiDaS; URI=http://www.tridas.org</dc:type>
     <dc:format>application/xml</dc:format>

- dc:language NEEDS TO BE DONE

- dc:description, temporal coverage, element/object type NEEDS TO BE DONE when license is OK

- dc:date
   From dccd-rest: stateChanged
   
   Example: 
   
       <dc:date>2012-04-16T12:42:26.344Z</dc:date>

- dc:identifier
  From dccd-rest: project sid and identifier
   
   Example: 
   
       <dc:identifier>dccd:6006</dc:identifier>
       <dc:identifier>D-11.0168</dc:identifier>

- dc:title
  From dccd-rest: project title
   
   Example: 
   
       <dc:title>Breda, Turfschip</dc:title>

- dc:subject
  From dccd-rest: category and type's
   
   Example: 
   
       <dc:subject>mobilia</dc:subject>
       <dc:subject>datering</dc:subject>

- dc:coverage
  From dccd-rest: location (lat lng)
   
   Example: 
   
       <dc:coverage>
          φλ=52.2439094680656 5.37347859251118; 
          projection=http://www.opengis.net/def/crs/EPSG/0/4326; units=decimal
       </dc:coverage>


Note that elements with internal structure that cannot be expressed by oai_dc are sometimes formatted as a list of key-value pairs:
key1=value1; key2=value2; ... keyN=valueN

For example the WGS94 coordinates in dc:coverage.  


### oai_acdm
This is the format used by the ARIADNE registry service and aims at archaeological collections and datasets. 

Transformation from the dccd-rest XML output is specified by the xsl file in: /dccd-oai/src/main/resources/dccd_to_oai_acdm.xsl

... DESCRIBED ELSEWHERE


Developer notes
---------------
This implementation is based on the approach by Fedora Commons (the archiving system we use) that uses the Proai library to run the service and handle data managent (keeping a database etc.). 
The proai lib can be configured to use a OAIDriver implementing class, which it must find on the class path. 

For the proai code see: [https://github.com/fcrepo/proai](https://github.com/fcrepo/proai)

When using Fedora there is a proai avaialable that gets the data from the Fedora Archive. 

For DCCD we descided NOT to use that and implement our own way of retrieving the datad needed for OAI. 
The DCCDOAIDriver retrieves the data from the DCCD using it's RESTfull API. It therfore depends on the REST service to run see: dccd-http project.  
This RESTfull service in turn is dependend on the (Solr) search index of DCCD. 
 
Instead of just copying the Ant project from the GitHub this project has been converted to a maven project and only the proai.jar and one other dependent jar needed to be included without maven. 


Get list of all projects via the RESTfull API; this is what proai sees when starting fresh!
Better use json because the response is more readable on the commandline.

	$ curl   -H "Accept: application/json"  http://localhost:8080/dccd-rest/rest/project
	
Because proai keeps a record of what it has harversted and then only looks for changes you have to reset it to a clean state while developping and testing. 
 	
Cleanup the proai cache and other temporary files. 

	$ rm -rf /tmp/proai/cache/*
	$ rm -rf /tmp/proai/schemas
	$ rm -rf /tmp/proai/sessions

Drop the tables from the proai database. 
You might also want to have a look at the contents by using pgAdmin and an ssh tunnel to get to your Postgres server. 

Or using psql

	$ psql -d proai -U proai -W
	proai=> DROP TABLE rcadmin, rcfailure, rcformat, rcitem, rcmembership, rcprunable, rcqueue, rcrecord, rcset;
	proai=> \q

	
Issues
------
This service does not support notification of deletion of records (DCCD projects). 

Because DCCD alows the 'unarchiving', potentially we could have a project that becomes unavailable (deleted for OAI). 

If we want to notify deleted records we only need the ID and the timestamp of the change. 
The current RESTfull API must be addapted to give this information via a GET on /deleted/projects/ ?
This can be inferred from the curent state (DRAFT) and previous state (PUBLISHED). But it should be investigated.
 


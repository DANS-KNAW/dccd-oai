/*******************************************************************************
 * Copyright 2015 DANS - Data Archiving and Networked Services
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
package nl.knaw.dans.dccd.oai;

import java.io.File;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DCCDMetaDataTransformer {
    private static Logger LOG = LoggerFactory.getLogger(DCCDMetaDataTransformer.class);

	/**
	 * Transforms the XML from the DCCD RESTfull API needs to be converted to XML for AOI. 
	 * For each 'type' of OAI output it uses an XSL file that specifies this tranformation.  
	 * This file must have the type in its filename: dccd_to_{type}.xsl.
	 * 
	 * @param xmlInStr
	 * @param type
	 * @return
	 * @throws TransformerException
	 */
	public static String transformXmlForOai(String xmlInStr, String type) throws TransformerException {
		LOG.debug("\nBefore transform:\n" + xmlInStr);

		//String xslRootPath = "/Users/paulboon/Documents/Development/dccd/dccd-oai/src/main/resources";
		
		// determine stylesheet based on the type
		// try to find the specific stylesheet
		//String xslFilePath = xslRootPath + "/" + "dccd_to_" + type + ".xsl"; // input xsl	
		
		//StreamSource xslSrc = getXslSourceFromFilePath(xslFilePath);
		StreamSource xslSrc = getXslSourceFromResourcePath("/dccd_to_" + type + ".xsl");
		
		// Create a transform factory instance.
		TransformerFactory tfactory = TransformerFactory.newInstance();

		// Can't disable validation...
		//tfactory.setValidating(false);
		//tfactory.setFeature("http://xml.org/sax/features/validation", false);
		//tfactory.setAttribute("http://xml.org/sax/features/validation", false);
		
		// Create a transformer for the stylesheet.
		Transformer transformer = tfactory.newTransformer(xslSrc);

		// prepare input and output
		StringReader xmlIn = new StringReader(xmlInStr);
		StringWriter xmlOut = new StringWriter();		

		// Transform the source XML
		transformer.transform(new StreamSource(xmlIn),
				new StreamResult(xmlOut ));
		
		LOG.debug("\nAfter transform:\n" + xmlOut.toString());
		return xmlOut.toString();
	}
	
	/**
	 * load xsl from an external file
	 * 
	 * @param xslPath
	 * @return
	 * @throws TransformerException
	 */
	public static StreamSource getXslSourceFromFilePath(String xslPath) throws TransformerException 
	{
		// test if it exist
		File f = new File(xslPath);
		if(!f.exists()){
			// bail out 
			throw new TransformerException("Stylesheet not found: " + xslPath);
		}

		return new StreamSource(new File(xslPath));
	}
	
	/**
	 * get xsl from the resources 
	 * 
	 * @param xslPath
	 * @return
	 */
	public static StreamSource getXslSourceFromResourcePath(String xslPath) throws TransformerException 
	{
		InputStream inputStream = DCCDMetaDataTransformer.class.getResourceAsStream(xslPath);
		
		if(inputStream == null){
			// bail out 
			throw new TransformerException("Stylesheet not found: " + xslPath);
		}

		return new StreamSource(inputStream);
	}
}

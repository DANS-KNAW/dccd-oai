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

import java.io.IOException;
import java.io.StringReader;
import java.net.URI;
import java.util.Date;

import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;
import org.joda.time.format.DateTimeFormatter;
import org.joda.time.format.ISODateTimeFormat;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;

/*
 * Retrieve record data (projects) from the DCCD archive. 
 * This is done via the DCCD's RESTfull interface.
 */
public class DCCDMetaDataService {
	private static Logger LOG = LoggerFactory.getLogger(DCCDMetaDataService.class);			
	private String dccdRestUrl;
	
	public String getDccdRestUrl() {
		return dccdRestUrl;
	}

	public void setDccdRestUrl(String dccdRestUrl) {
		this.dccdRestUrl = dccdRestUrl;
	}

	/**
	 * Retrieve the XML for the specified project
	 * 
	 * @param sid
	 * @return
	 */
	public String getProjectXML(String sid)
	{		
		String url = getDccdRestUrl() + "/project/" + sid;
		//LOG.debug("######## REST url: " + url);
		
		Client client = Client.create();
        WebResource resource = client.resource(url);
        ClientResponse response = resource
                //.accept(MediaType.APPLICATION_XML)
                .get(ClientResponse.class);

        if (Response.Status.OK.getStatusCode() != response.getStatus()) {
        	return null;
        }

        String rStr = response.getEntity(String.class);
		return rStr;
	}

	/**
	 * Retrieve the XML for all the project that changed within the given dates
	 * 
	 * @param from
	 * @param until
	 * @return
	 */
	public String getProjectListXML(Date from, Date until)
	{		
		String url = getDccdRestUrl() + "/project";
		
		// convert to UTC and format as ISO
		DateTimeFormatter fmt = ISODateTimeFormat.dateTime();
		DateTime dUtc = new DateTime(from).toDateTime(DateTimeZone.UTC);
		String fromStr = fmt.print(dUtc);		
		dUtc = new DateTime(until).toDateTime(DateTimeZone.UTC);
		String untilStr = fmt.print(dUtc);		
		
		URI uri = UriBuilder.fromUri(url)
			.queryParam("modFrom", fromStr)
			.queryParam("modUntil", untilStr)
			.queryParam("limit", "1000000000") // need to specify a large number to get all results!
			.build();
		
		LOG.debug("get project info with REST url: " + uri.toString());
		
		Client client = Client.create();
        WebResource resource = client.resource(uri);
        ClientResponse response = resource
                //.accept(MediaType.APPLICATION_XML)
                .get(ClientResponse.class);

        if (Response.Status.OK.getStatusCode() != response.getStatus()) {
        	return null;
        }

        String rStr = response.getEntity(String.class);
		return rStr;
	}

	/**
	 * get the timestamp for the latest change in the archive that OAI must know about. 
	 * 
	 * @return
	 */
	public Date getLatestDate() 
	{
		String xmlStr = getLastProjectXML();
		if (xmlStr == null)
			return null;
		
		// now try to get the date from the XML
		// xpath would be: /projects/project/stateChanged
		// use DOM parser
		try {
			DocumentBuilderFactory dbf =
					DocumentBuilderFactory.newInstance();
			DocumentBuilder db = dbf.newDocumentBuilder();
			Document doc = db.parse(new InputSource(new StringReader(xmlStr)));
			NodeList nodes = doc.getElementsByTagName("stateChanged");
			// should be one and only one!
			Element element = (Element) nodes.item(0);
			String dateStr = element.getTextContent();
			
			// convert to a date
			DateTimeFormatter fmt = ISODateTimeFormat.dateTime();
			return fmt.parseDateTime(dateStr).toDate();
		} catch (ParserConfigurationException e) {
			e.printStackTrace();
		} catch (SAXException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return null;
	}

	/**
	 * Retrieve the XML for the project that changed last
	 * 
	 * The rest interface will return the results of a request for project 
	 * with a date restriction (from , until) sorted on the date. 
	 * And the latest one will be the first in the list of results. 
	 * So if we ask for just one project of all since the beginning, we get the one that changed last. 
	 * 
	 * @return
	 */
	private String getLastProjectXML()
	{		
		String url = getDccdRestUrl() + "/project";
		Date from = new Date(0); // before the archive existed
		
		// convert to UTC and format as ISO
		DateTimeFormatter fmt = ISODateTimeFormat.dateTime();
		DateTime dUtc = new DateTime(from).toDateTime(DateTimeZone.UTC);
		String fromStr = fmt.print(dUtc);		
		
		URI uri = UriBuilder.fromUri(url)
			.queryParam("modFrom", fromStr)
			.queryParam("offset", "0")
			.queryParam("limit", "1")
			.build();
		
		LOG.debug("get last project with REST url: " + uri.toString());
		
		Client client = Client.create();
        WebResource resource = client.resource(uri);
        ClientResponse response = resource
                //.accept(MediaType.APPLICATION_XML)
                .get(ClientResponse.class);

        if (Response.Status.OK.getStatusCode() != response.getStatus()) {
        	return null;
        }

        String rStr = response.getEntity(String.class);
		return rStr;
	}
	
}

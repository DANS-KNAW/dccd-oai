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
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import proai.Record;

/**
 * For SAX parsing the lists of projects from the DCCD archive
 * Note that we still need the whole XML as String in memory. 
 * 
 * @author paulboon
 *
 */
public class DCCDMetaDataListParser extends DefaultHandler {
	private static Logger LOG = LoggerFactory.getLogger(DCCDMetaDataListParser.class);
	private String mdPrefix;
	private List<Record> records;
	private String tempVal; // last parsed value
	//to maintain context
	private DCCDRecord tempRec;

	public DCCDMetaDataListParser(String mdPrefix) {
		super();
		this.mdPrefix = mdPrefix;
		records = new ArrayList<Record>();
	}
	
	public List<Record> getRecords() {
		return records;
	}

	public void parse(String xml)
	{
		SAXParserFactory spf = SAXParserFactory.newInstance();
		try {
			SAXParser sp = spf.newSAXParser();
			
			// reset
			tempVal = "";	
			records.clear();
			
			//parse the file and also register this class for call backs
			sp.parse(new InputSource(new StringReader(xml)), this);
			
		}catch(SAXException se) {
			se.printStackTrace();
		}catch(ParserConfigurationException pce) {
			pce.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public void characters(char[] ch, int start, int length)
			throws SAXException {
		if (tempVal == null)
		{
			tempVal = new String(ch, start, length);			
		}
		else
		{
			// Note that it can be called several times, each with another chunk
			tempVal += new String(ch, start, length);
		}
	}

	@Override
	public void startElement(String uri, String localName, String qName,
			Attributes attributes) throws SAXException {
		//reset only val
		tempVal = null;//"";
		
		if(qName.equalsIgnoreCase("project")) {
			tempRec = new DCCDRecord();
			tempRec.setPrefix(mdPrefix);
		}
	}

	@Override
	public void endElement(String uri, String localName, String qName)
			throws SAXException {
		// one and only one sid per project
		if(qName.equalsIgnoreCase("project")) 
		{
			//add it to the list
			records.add(tempRec);
			LOG.debug("Project parsed with change date: " + tempRec.getSourceInfo());
		} 
		else if (qName.equalsIgnoreCase("sid")) 
		{
			String sid = tempVal;
			String itemID = sid;
			tempRec.setItemID(itemID);
		}
		else if (qName.equalsIgnoreCase("stateChanged")) 
		{
			String sourceInfo = tempVal;
			tempRec.setSourceInfo(sourceInfo);
		}
	}

}

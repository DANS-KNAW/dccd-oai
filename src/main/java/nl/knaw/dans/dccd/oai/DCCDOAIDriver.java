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
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Properties;

import javax.xml.transform.TransformerException;

import org.apache.commons.io.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import proai.MetadataFormat;
import proai.Record;
import proai.SetInfo;
import proai.driver.OAIDriver;
import proai.driver.RemoteIterator;
import proai.driver.impl.MetadataFormatImpl;
import proai.driver.impl.RemoteIteratorImpl;
import proai.error.RepositoryException;

/**
 * The web service in  proai periodically calls methods of the 'Driver' object (sort of harvesting your data). 
 * It will handle changes in the data and store everything in the database (and cache some ). 
 * It uses this database to get the data when requested for it. 
 * So it is not calling the driver code directly when handling a request 
 * and you have to wait for the next 'cycle' to see changes. 
 * 
 * @author paulboon
 *
 */
public class DCCDOAIDriver  implements OAIDriver {
	private static final Logger LOG   = LoggerFactory.getLogger(DCCDOAIDriver.class);
	private static final String REST_URL_PROP_KEY = "driver.dccd.rest.url";
	private static final String DEFAULT_REST_URL = "http://localhost:8080/dccd-rest/rest";

	private DCCDMetaDataService dccdMetaDataService;
	
	public DCCDOAIDriver () {/* empty */}
	
	@Override
	public void init(Properties props) throws RepositoryException {

		String dccdRestUrl = props.getProperty(REST_URL_PROP_KEY, DEFAULT_REST_URL);
		dccdMetaDataService = new DCCDMetaDataService();
		dccdMetaDataService.setDccdRestUrl(dccdRestUrl);
	}

	@Override
	public void close() throws RepositoryException {/* empty */	}

	@Override
	public Date getLatestDate() throws RepositoryException {
		LOG.debug("getLatestDate");
	
		// Note for testing
		//return new Date(); // just NOW, forcing it to always retrieve the metadata and 'update' ?
		//
		//		Date errorResult = new Date(0); // before the archive existed, so Nothing changed. 
		// seems best not to trigger any updating if there is an error.
		
		Date latestDate = dccdMetaDataService.getLatestDate();
		return latestDate;	
	}

	@Override
	public RemoteIterator<? extends MetadataFormat> listMetadataFormats()
			throws RepositoryException {		
		LOG.debug("listMetadataFormats");
		return new RemoteIteratorImpl<MetadataFormat>(getMetadataFormatCollection().iterator());
	}

	@Override
	public RemoteIterator<? extends Record> listRecords(Date from, Date until,
			String mdPrefix) throws RepositoryException {
		LOG.debug("listRecords: " + from.toString() + ", " + until.toString() + ", " + mdPrefix);

		return new RemoteIteratorImpl<Record>(getRecordCollection(from, until, mdPrefix).iterator());
	}

	@Override
	public void writeRecordXML(String itemID, String mdPrefix, String sourceInfo, PrintWriter writer) throws RepositoryException {
		LOG.debug("writeRecordXML: " + itemID + ", " + mdPrefix + ", " + sourceInfo);
		
		// SID is stored in itemID, but other info is in sourceInfo
		// Note that it 
		String metadata = dccdMetaDataService.getProjectXML(itemID);		 
		 
		 if (metadata == null)
			 throw new RepositoryException("DCCD Data Service failed to retrieve project: " + itemID);
		 
		// NOTE only support oai_dc
		 
		// Transform the xml to oai_dc
		try {
			metadata = DCCDMetaDataTransformer.transformXmlForOai(metadata, mdPrefix);
		} catch (TransformerException e) {
			throw new RepositoryException(e.getMessage());
		}
	 		 
		// Get extra data from the sourceInfo
		// NOTE we need to provide it but proai places the harversting timestamp into this 
		String datestamp = sourceInfo; 
		String setSpec = "dccd"; // Fixed for now, but might be coming from the sourceInfo in the future
		metadata = 
					  "<record>\n"
					+ "  <header>\n"
					+ "    <identifier>" + itemID + "</identifier>\n"
					+ "    <datestamp>" + datestamp + "</datestamp>\n"
					+ "    <setSpec>" + setSpec + "</setSpec>\n"
					+ "  </header>\n"
					+ "  <metadata>\n"
					+ metadata
					+ "</metadata>\n"
					+ "</record>";
		
		writer.print(metadata);
	}

	@Override
	public RemoteIterator<? extends SetInfo> listSetInfo()
			throws RepositoryException {
		LOG.debug("listSetInfo");
		
		return new RemoteIteratorImpl<SetInfo>(getSetInfoCollection().iterator());
	}

	@Override
	public void write(PrintWriter out) throws RepositoryException {
		LOG.debug("write");

		// Note that if we change the deletion policy we need to change this
		// We just do nothing yet with deletions; <deletedRecord>no</deletedRecord>. 
		// At some point we should be able to make it transient
		// see http://www.openarchives.org/OAI/openarchivesprotocol.html#DeletedRecords
		
		try {
			// Note that we don't have a XML declaration in the file, it should begin with <Identify>
			InputStream inputStream = DCCDOAIDriver.class.getResourceAsStream("/identify.xml");
			String xmlStr = IOUtils.toString(inputStream, "UTF-8");
			out.print(xmlStr);
		} catch (IOException e) {
			throw new RepositoryException(e.getMessage());
		}

		/* HARDCODED
		String xmlStr  = 
				  "<Identify>\n"
				+ "    <repositoryName>DCCD Archive</repositoryName>\n"
				+ "    <baseURL>http://dendro.dans.knaw.nl/oai</baseURL>\n"
				+ "    <protocolVersion>2.0</protocolVersion>\n"
				+ "    <adminEmail>info@dans.knaw.nl</adminEmail>\n"
				+ "    <earliestDatestamp>2005-07-01T12:00:00Z</earliestDatestamp>\n"
				+ "    <deletedRecord>no</deletedRecord>\n"
				+ "    <granularity>YYYY-MM-DDThh:mm:ssZ</granularity>\n"
				+ "    <description>\n"
				+ "        <oai-identifier xmlns=\"http://www.openarchives.org/OAI/2.0/oai-identifier\" \n"
				+ "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \n"
				+ "xsi:schemaLocation=\"http://www.openarchives.org/OAI/2.0/oai-identifier         \n"
				+ "http://www.openarchives.org/OAI/2.0/oai-identifier.xsd\">\n"
				+ "        <scheme>oai</scheme>\n"
				+ "        <repositoryIdentifier>dendro.dans.knaw.nl</repositoryIdentifier>\n"
				+ "        <delimiter>:</delimiter>\n"
				+ "        <sampleIdentifier>oai:dendro.dans.knaw.nl:dccd:1</sampleIdentifier>\n"
				+ "        </oai-identifier>\n"
				+ "    </description>\n"
				+ "</Identify>";
		
		out.print(xmlStr);
		*/
	}

	private Collection<MetadataFormat> getMetadataFormatCollection() {
		List<MetadataFormat> list = new ArrayList<MetadataFormat>();
		
		// ONLY oai_dc
		list.add(new MetadataFormatImpl("oai_dc", 
				"http://www.openarchives.org/OAI/2.0/oai_dc/",
				"http://www.openarchives.org/OAI/2.0/oai_dc.xsd"));

		// ARIADNE acdm
		list.add(new MetadataFormatImpl("oai_acdm", 
				"http://registry.ariadne-infrastructure.eu/",
				"http://registry.ariadne-infrastructure.eu/schema_definition/6.8/acdm.xsd"));
		
		return list;
	}
	
	private Collection<SetInfo> getSetInfoCollection() {
		List<SetInfo> list = new ArrayList<SetInfo>();
		// DCCD has no sets yet... everything is dccd
		// But proai needs at least one SetInfo, otherwise it won't show Records. 
		// 
		// everything published in the DCCD archive 
		list.add(new DCCDSetInfo("dccd", "dccd", "All published projects in the dccd archive"));
		
		return list;
	}
	
	private Collection<Record> getRecordCollection(Date from, Date until,
			String mdPrefix) {
		
		String result = dccdMetaDataService.getProjectListXML(from, until);	 
		if (result == null)
			throw new RepositoryException("DCCD Data Service failed to retrieve project list");
	
		// get the ID's from this XML by SAX parsing
		DCCDMetaDataListParser parser = new DCCDMetaDataListParser(mdPrefix);
		parser.parse(result);
		return parser.getRecords();
	}
}

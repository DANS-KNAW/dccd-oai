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

import java.io.PrintWriter;

import proai.SetInfo;
import proai.error.ServerException;

public class DCCDSetInfo implements SetInfo {
		    private String m_setSpec;
			private String m_setName;
		    private String m_setDesc;

		    public DCCDSetInfo(String setSpec, String setName, String setDesc) {
		        m_setSpec = setSpec;
		        m_setName = setName;
		        m_setDesc = setDesc;
		    }

		    public String getSetSpec() {
		        return m_setSpec;
		    }

		    public String getSetName() {
				return m_setName;
			}

			public String getSetDesc() {
				return m_setDesc;
			}

			@Override
			public void write(PrintWriter out) throws ServerException {
				String xmlStr  = 
						"<set>\n"
						+ "<setSpec>" + getSetSpec() + "</setSpec>\n"
						+ "<setName>" + getSetName() + "</setName>\n"
						+ "<setDescription>\n"
						+ "<oai_dc:dc xmlns:oai_dc=\"http://www.openarchives.org/OAI/2.0/oai_dc/\" \n"
						+ "xmlns:dc=\"http://purl.org/dc/elements/1.1/\" \n"
						+ "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \n"
						+ "xsi:schemaLocation=\"http://www.openarchives.org/OAI/2.0/oai_dc/ \n"
						+ "http://www.openarchives.org/OAI/2.0/oai_dc.xsd\">\n"
						+ "<dc:description>\n"
						+ getSetDesc()
						+ "</dc:description>\n"
						+ "</oai_dc:dc>\n"
						+ "</setDescription>\n"
						+ "</set>\n";
				
				out.print(xmlStr);
			}
}

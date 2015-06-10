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

import proai.Record;

public class DCCDRecord implements Record {
	private String itemID;
    private String prefix;
    private String sourceInfo;

    public DCCDRecord() {}
    
    public DCCDRecord(String itemID, String prefix, String sourceInfo) {
        this.itemID = itemID;
        this.prefix = prefix;
        this.sourceInfo = sourceInfo;
    }
    
    @Override
	public String getItemID() {
		return itemID;
	}

	@Override
	public String getPrefix() {
		return prefix;
	}

	@Override
	public String getSourceInfo() {
		return sourceInfo;
	}

	public void setItemID(String itemID) {
		this.itemID = itemID;
	}

	public void setPrefix(String prefix) {
		this.prefix = prefix;
	}

	public void setSourceInfo(String sourceInfo) {
		this.sourceInfo = sourceInfo;
	}
}

/*******************************************************************************
 * This is the copyright work of The MITRE Corporation, and was produced for the 
 * U. S. Government under Contract Number DTFAWA-10-C-00080, as well as subject 
 * to the Apache Licence, Version 2.0 dated January 2004. 
 * 
 * For further information, please contact The MITRE Corporation, Contracts Office, 
 * 7515 Colshire Drive, McLean, VA  22102-7539, (703) 983-6000.
 * 
 * Copyright 2011 The MITRE Corporation
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * 
 * You may obtain a copy of the License at
 * 
 * 	    http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
package com.mitre.holdshort;

import java.util.ArrayList;
import java.util.List;


public class RunwayManager {

	List<RunwayBar> rwyList;
	List<RunwayZone> runways;
	List<RunwayBar> rwyHoldShort;
	String airportToFind;

	public RunwayManager(){		
		runways = new ArrayList<RunwayZone>();
		rwyList = new ArrayList<RunwayBar>();
		rwyHoldShort = new ArrayList<RunwayBar>();
				
	}

	public void addRunway(RunwayBar rwy) {
		rwyList.add(rwy);
	}
	
	public void addHoldShortRwy(RunwayBar rwy) {
		rwyHoldShort.add(rwy);
	}
	
	public int getRunwaySize (){
		return runways.size();
	}
	
	public int getRwyHoldShortSize(){
		return rwyHoldShort.size();
	}
	
	public void updateHoldShortStatus(){
		
		rwyHoldShort.clear();
		for (int i=0; i<getRunwaySize(); i++){
			if(runways.get(i).getRunwayBar().isHoldSet()){
				rwyHoldShort.add(runways.get(i).getRunwayBar());
			}
		}
		
	}

	
	public String getAirportToFind() {
		return airportToFind;
	}

	public void setAirportToFind(String airportToFind) {
		this.airportToFind = airportToFind;
	}

}

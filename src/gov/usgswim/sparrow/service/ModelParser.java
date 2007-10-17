package gov.usgswim.sparrow.service;

import gov.usgswim.service.AbstractHttpRequestParser;

import gov.usgswim.service.RequestParser;

import javax.servlet.http.HttpServletRequest;

import javax.xml.stream.XMLStreamReader;

public class ModelParser extends AbstractHttpRequestParser<ModelRequest> implements RequestParser<ModelRequest> {

	public ModelParser() {
	}

	public ModelRequest parse(HttpServletRequest request) throws Exception {
		XMLStreamReader reader = getXMLStream(request);
		return parse(reader);
	}

	public ModelRequest parse(String in) throws Exception {
		XMLStreamReader reader = getXMLStream(in);
		return parse(reader);
	}
	
	public ModelRequest parse(XMLStreamReader reader) throws Exception {
		ModelRequest req = null;

		while (reader.hasNext()) {
			int eventCode = reader.next();
			
			switch (eventCode) {
			case XMLStreamReader.START_ELEMENT:
				String lName = reader.getLocalName();
				
				if ("model".equals(lName)) {
					req = new ModelRequest();
					
					if (reader.getAttributeCount() > 0) {
						for (int i = 0; i < reader.getAttributeCount(); i++)  {
							String name = reader.getAttributeLocalName(i);
							String val = reader.getAttributeValue(i);
							if ("public".equals(name)) {
								req.setPublic(val);
							} else if ("approved".equals(name)) {
								req.setApproved(val);
							} else if ("archived".equals(name)) {
								req.setArchived(val);
							}
						}
						
						
					}
					
					
				} else if ("source".equals(lName)) {
					req.setSources(true);
				}
				
				
				break;
			}
		}
		
		return req;
	}


}
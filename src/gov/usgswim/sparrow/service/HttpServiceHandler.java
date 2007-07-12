package gov.usgswim.sparrow.service;

import java.io.IOException;

import javax.servlet.http.HttpServletResponse;

import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;

/**
 * A low-level service interface that defines a service capable of taking an
 * incoming XML stream and returning a HttpServletResponse.
 */
public interface HttpServiceHandler extends ServiceHandler {
	public void dispatch(XMLStreamReader in, HttpServletResponse response) throws XMLStreamException, IOException;
}

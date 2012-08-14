package th.in.veer66.yaitron;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Stack;
import javax.xml.namespace.QName;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.events.XMLEvent;

public class YaitronTeiReader implements Iterator<Entry> {
	XMLEventReader reader;
	Entry nextEntry = null;
	String form = null;
	Stack<String> tagStack = new Stack<String>();

	public YaitronTeiReader(InputStream is) throws XMLStreamException,
			InvalidFormatException {
		XMLInputFactory factory = XMLInputFactory.newFactory();
		reader = factory.createXMLEventReader(is);
		nextEntry = readEntry();
	}

	private boolean startElementTagCompare(XMLEvent event, String localPart) {
		return localPart
				.equals(event.asStartElement().getName().getLocalPart());
	}

	private Entry createEntry(XMLEvent event) {
		return new Entry(event
				.asStartElement()
				.getAttributeByName(
						new QName("http://www.w3.org/XML/1998/namespace",
								"lang", "xml")).getValue());
	}

	private void checkParentTag(XMLEvent event, Stack<String> tagStack,
			String expectedParent) throws InvalidFormatException {
		if (!expectedParent.equals(tagStack.peek())) {
			throw new InvalidFormatException(event.asStartElement().getName()
					.getLocalPart()
					+ " is not in " + expectedParent);
		}
	}

	protected Entry readEntry() throws XMLStreamException,
			InvalidFormatException {
		Entry entry = null;
		List<Translation> translations = new ArrayList<Translation>();
		List<Reference> refs = new ArrayList<Reference>();

		boolean isCitExample = false;

		while (reader.hasNext()) {
			XMLEvent event = reader.nextEvent();
			if (event.isStartElement()) {
				if (tagStack.empty()) {
					if (!startElementTagCompare(event, "TEI")) {
						throw new InvalidFormatException(
								"The first tag is not TEI");
					}
				} else {
					if (startElementTagCompare(event, "entry")) {
						checkParentTag(event, tagStack, "body");
						entry = createEntry(event);
					} else if (startElementTagCompare(event, "form")) {
						checkParentTag(event, tagStack, "entry");
					} else if (startElementTagCompare(event, "orth")) {
						checkParentTag(event, tagStack, "form");
					} else if (startElementTagCompare(event, "gramGrp")) {
						checkParentTag(event, tagStack, "entry");
					} else if (startElementTagCompare(event, "pos")) {
						checkParentTag(event, tagStack, "gramGrp");
					} else if (startElementTagCompare(event, "cit")) {
						checkParentTag(event, tagStack, "entry");
						addTranslation(translations, event);
						if ("example".equals(getValueFromAttribute(event,
								"type")))
							isCitExample = true;
					} else if (startElementTagCompare(event, "quote")) {
						checkParentTag(event, tagStack, "cit");
					} else if (startElementTagCompare(event, "xr")) {
						checkParentTag(event, tagStack, "entry");
						addRef(refs, event);
					} else if (startElementTagCompare(event, "ref")) {
						checkParentTag(event, tagStack, "xr");
					}
				}
				tagStack.push(event.asStartElement().getName().getLocalPart());
			} else if (event.isEndElement()) {
				if (tagStack.peek().equals(
						event.asEndElement().getName().getLocalPart())) {
					if ("cit".equals(tagStack.peek())) {
						isCitExample = false;
					}
					tagStack.pop();
					if ("entry".equals(event.asEndElement().getName()
							.getLocalPart())) {
						entry.setTranslations(translations
								.toArray(new Translation[translations.size()]));
						entry.setReferences(refs.toArray(new Reference[refs
								.size()]));
						break;
					}
				}
			} else if (event.isCharacters()) {
				if (tagStack.peek().equals("orth")) {
					entry.setForm(event.asCharacters().getData());
				} else if (tagStack.peek().equals("pos")) {
					entry.setPos(event.asCharacters().getData());
				} else if (tagStack.peek().equals("quote")) {
					if (isCitExample) {
						entry.setExample(event.asCharacters().getData());
					} else {
						if (translations.size() > 0)
							translations.get(translations.size() - 1).setText(
									event.asCharacters().getData());
					}
				} else if (tagStack.peek().equals("ref")) {
					// refs.get(refs.size() - 1).setText(
					// event.asCharacters().getData());
				}
			}
		}
		return entry;
	}

	private void addRef(List<Reference> refs, XMLEvent event)
			throws InvalidFormatException {
		if ("syn".equals(getValueFromAttribute(event, "type"))) {
			refs.add(new Synonym());
		} else if ("ant".equals(getValueFromAttribute(event, "type"))) {
			refs.add(new Antonym());
		} else if ("cl".equals(getValueFromAttribute(event, "type"))) {
			refs.add(new Classifier());
		} else {
			throw new InvalidFormatException("Invalid xr type = "
					+ getValueFromAttribute(event, "type"));
		}
	}

	private void addTranslation(List<Translation> translations, XMLEvent event)
			throws InvalidFormatException {
		if ("translation".equals(getValueFromAttribute(event, "type"))) {
			if (null == getValueFromAttribute(event, "subtype")) {
				translations.add(new ExactTranslation(
						getValueFromAttributeW3NS(event, "lang", "xml")));
			} else if ("similar"
					.equals(getValueFromAttribute(event, "subtype"))) {
				translations.add(new SimilarTranslation(
						getValueFromAttributeW3NS(event, "lang", "xml")));
			} else {
				throw new InvalidFormatException("cit subtype is not 'similar'");
			}
		}
	}

	private String getValueFromAttribute(XMLEvent event, String localPart) {
		String value = null;
		if (event.asStartElement().getAttributeByName(new QName(localPart)) != null) {
			value = event.asStartElement()
					.getAttributeByName(new QName(localPart)).getValue();
		}
		return value;
	}

	private String getValueFromAttributeW3NS(XMLEvent event, String localPart,
			String prefix) {
		String value = null;
		if (event.asStartElement().getAttributeByName(
				new QName("http://www.w3.org/XML/1998/namespace", localPart)) != null) {
			value = event
					.asStartElement()
					.getAttributeByName(
							new QName("http://www.w3.org/XML/1998/namespace",
									localPart, prefix)).getValue();
		}
		return value;
	}

	@Override
	public boolean hasNext() {
		return nextEntry != null;
	}

	@Override
	public Entry next() {
		Entry thisEntry = nextEntry;
		try {
			nextEntry = readEntry();
		} catch (XMLStreamException e) {
			nextEntry = null;
		} catch (InvalidFormatException e) {
			nextEntry = null;
		}
		return thisEntry;
	}

	@Override
	public void remove() {
		// TODO Auto-generated method stub

	}

}

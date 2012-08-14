package th.in.veer66.yaitron;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.charset.Charset;

import javax.xml.stream.XMLStreamException;


/**
 * Hello world!
 *
 */



public class App 
{
    public static void main( String[] args ) throws XMLStreamException, IOException, InvalidFormatException
    {
    	System.out.println("Default Charset=" + Charset.defaultCharset());

    	FileInputStream fis = new FileInputStream(args[0]);
    	YaitronTeiReader reader = new YaitronTeiReader(fis);
    	int i = 0;
    	System.out.println("file.encoding=" + System.getProperty("file.encoding"));
    	System.out.println("Default Charset=" + Charset.defaultCharset());

    	while(reader.hasNext()) {
    		i++;
    		Entry e = reader.next();
    		System.out.println(e.getForm());
    		System.out.println(e.getLang());
    		System.out.println(e.getPos());
    		for(Translation t : e.getTranslations()) {
    			System.out.println("* " + t.getText() + " " + t.getLang());
    		}
    		System.out.println(e.getExample());
    		System.out.println("-----");
    		for(Reference r : e.getReferences()) {
    			System.out.println("# " + r);
    		}
    	}
    	System.out.println(i);
    	fis.close();
    }
}

package th.in.veer66.yaitron;

public class AbstractReference implements Reference {

	protected String text;
	
	@Override
	public void setText(String text) {
		this.text = text;
	}
	
	@Override
	public String getText() {
		return text;
	}

}

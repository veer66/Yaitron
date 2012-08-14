package th.in.veer66.yaitron;

public abstract class AbstractTranslation implements Translation {
	protected String lang;
	protected String text;

	public AbstractTranslation(String lang) {
		this.lang = lang;
	}
	
	@Override
	public String getText() {
		return text;
	}

	@Override
	public void setText(String text) {
		this.text = text;
	}
	
	@Override
	public String getLang() {
		return lang;
	}
	
	@Override
	public void setLang(String lang) {
		this.lang = lang;
	}
}

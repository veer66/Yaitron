package th.in.veer66.yaitron;

public class Entry {

	private String lang;
	private String form;
	private String pos = null;
	private Translation[] translations;
	private Reference[] references;
	public Reference[] getReferences() {
		return references;
	}

	public void setReferences(Reference[] references) {
		this.references = references;
	}

	private String example;

	public Entry(String lang) {
		this.lang = lang;
	}

	public Translation[] getTranslations() {
		return translations;
	}

	public void setTranslations(Translation[] translations) {
		this.translations = translations;
	}

	public String getLang() {
		return lang;
	}

	public String getForm() {
		return form;
	}

	public String getPos() {
		return pos;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public void setForm(String form) {
		this.form = form;
	}

	public void setPos(String pos) {
		if (this.pos != null) {
			System.out.println("Too many POS");
		}
		this.pos = pos;
	}

	public void setExample(String example) {
		this.example = example;
	}
	
	public String getExample() {
		return example;
	}
	
	
}

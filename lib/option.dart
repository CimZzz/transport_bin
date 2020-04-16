enum OptionType {
	Type_String,
	Type_Int,
	Type_None,
}

typedef RootHandle = void Function(RootOption rootOption, Map<String, dynamic> valueMap);

class RootOption {
    RootOption({this.optionName, this.optionList, this.info, this.rootHandle});

	final List<String> optionName;
	final List<Option> optionList;
    final String info;
	final RootHandle rootHandle;

	String selectName;

    Map<String, dynamic> _valueMap;

    void addOption(String key, dynamic value) {
	    _valueMap ??= {};
	    _valueMap[key] = value;
    }

    bool checkOptionExist(String key) => _valueMap?.containsKey(key) ?? false;

    void perform() {
    	rootHandle(this, _valueMap);
    }
}

class Option {
    Option({this.optionName, this.optionType, this.valueName, this.mustOnly, this.info});
	final List<String> optionName;
	final OptionType optionType;
    final String valueName;
    final bool mustOnly;
    final String info;

    String selectName;
}
public class FieldSetReactor 
{
	// class level collection to hold field describe information
	public static Map<String, Schema.SObjectField> fieldDescribe = new Map<String, Schema.SObjectField>();
	public static List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();

	// object that holds details about a given field
	public class FieldDetails
	{
		// attributes set for all fields
		public String label;
		public String name;
		public Boolean required;
		public String dataType;
		public Boolean hasReadAccess;
		public Boolean hasCreateAccess;
		public Boolean hasEditAccess;
		public Object defaultValue;
		public String helpText;
		
		// attributes set depending upon dataType
		public Integer length;
		public Integer precision;
		public Integer scale;
		public String objectReferenced;
		public List<String> picklistValues;
	}

	// method accepts field set name and object, returns List of FieldDetails
	@RemoteAction
	public static List<FieldDetails> getFieldDetails(String fieldSetName, String sObjectName)
	{
		// describe the object
		SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
		Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
		
		// get field map for given SObject
		fieldDescribe = objectType.getDescribe().fields.getMap();

		// get field set members for given fieldSet
		fieldSetMembers = objectDescribe.FieldSets.getMap().get(fieldSetName).getFields();

		// instantiate map to hold FieldDetails for given field
		List<FieldDetails> fieldDetailsList = new List<FieldDetails>();

		// loop over fieldSetMembers to begin populating fieldDetailsList
		for(Schema.FieldSetMember field : fieldSetMembers)
		{
			FieldDetails detail = new FieldDetails();
			detail.label = field.getLabel();
			detail.name = field.getFieldPath();
			detail.required = field.getDbRequired() || field.getRequired() ? true : false;
			detail.dataType = String.valueOf(field.getType());

			// describe specified field
			Schema.DescribeFieldResult fieldDescription = fieldDescribe.get(detail.name).getDescribe();
			
			// source from fieldDescribe
			detail.hasReadAccess = fieldDescription.isAccessible();
			detail.hasCreateAccess = fieldDescription.isCreateable();
			detail.hasEditAccess = fieldDescription.isUpdateable();
			detail.defaultValue = fieldDescription.getDefaultValue();
			detail.helpText = fieldDescription.getInlineHelpText();

			if(detail.dataType == 'Currency' || detail.dataType == 'Double' || detail.dataType == 'Percent')
			{
				detail.precision = fieldDescription.getPrecision();
				detail.scale = fieldDescription.getScale();
			}
			else if(detail.dataType == 'Integer')
			{
				detail.precision = fieldDescription.getPrecision();
				detail.scale = 0;
			}
			else if(detail.dataType == 'Combobox' || detail.dataType == 'Email' || detail.dataType == 'EncryptedString' || detail.dataType == 'Phone' || detail.dataType == 'String' || detail.dataType == 'TextArea' || detail.dataType == 'URL')
			{
				detail.length = fieldDescription.getLength();
			}
			else if(detail.dataType == 'MultiPicklist' || detail.dataType == 'Picklist')
			{
				List<String> picklistValues = new List<String>();
				
				// iterate over picklist entries for active values
				for(Schema.PicklistEntry entry : fieldDescription.getPicklistValues())
				{
					if(entry.isActive())
					{
						picklistValues.add(entry.getLabel());
						
						// if the active value is default value, set as defaultValue
						if(entry.isDefaultValue())
						{
							detail.defaultValue = entry.getLabel();
						}
					}
				}

				// set the picklistValues as the list of strings
				detail.picklistValues = picklistValues;
			}
			else if(detail.dataType == 'Reference')
			{
				detail.objectReferenced = String.valueOf(fieldDescription.getReferenceTo());
			}

			// put detail into the fieldDetails Map
			fieldDetailsList.add(detail);
		}

		// return fieldDetailsList
		return fieldDetailsList;
	}
}
@isTest
private class FieldSetReactorTest 
{
	static testMethod void verifyUserFieldSetReturn()
	{
		// set of expected fields
		Set<String> fieldNames = new Set<String>{
			'Title',
			'Email',
			'Username',
			'IsActive',
			'CreatedDate',
			'CreatedById',
			'LocaleSidKey'
		};

		// instantiate collection to hold results
		List<FieldSetReactor.FieldDetails> userFieldSetDetails = new List<FieldSetReactor.FieldDetails>();

		// retrieve field set details for the User field set included in package
		userFieldSetDetails = FieldSetReactor.getFieldDetails('FieldSetReactor', 'User');

		// package ships with 7 fields included
		System.assertEquals(7, userFieldSetDetails.size());

		// iterate over return to confirm that 
		for(FieldSetReactor.FieldDetails field : userFieldSetDetails)
		{
			System.assert(fieldNames.contains(field.name));
		}
	}
}
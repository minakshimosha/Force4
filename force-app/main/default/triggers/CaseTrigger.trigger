trigger CaseTrigger on Case (before Insert, before Update, after Insert, after Update) {
    
    Map<Id,Case> caseMap = new Map<Id,Case>();
    List<Case> listCasetobeCreated = new List<Case>();
    //Fetching the assignment rules on case
	AssignmentRule AR = new AssignmentRule();
	AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

	//Creating the DMLOptions for "Assign using active assignment rules" checkbox
	Database.DMLOptions dmlOpts = new Database.DMLOptions();
	dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
    
    Id childRecordTypeID = [select Id from RecordType where sObjectType='Case' and DeveloperName='Feedback'].Id;
    Id mainRecordTypeID = [select Id from RecordType where sObjectType='Case' and DeveloperName='Main'].Id;
    if(trigger.isUpdate && trigger.isAfter){
        System.debug('Inside is after');
        for(Case c: trigger.new){
            System.debug('old value'+trigger.oldMap.get(c.Id).Feedback_Sentiment__c+ c.Feedback_Sentiment__c+ mainRecordTypeID);
            if((trigger.oldMap.get(c.Id).Feedback_Sentiment__c != c.Feedback_Sentiment__c && c.Feedback_Sentiment__c == 'Negative') && c.RecordTypeId == mainRecordTypeID){
                System.debug('Inside is main if');
                Case childCase = new Case();
                childCase.setOptions(dmlOpts);
                childCase.RecordTypeId = childRecordTypeID;
                childCase.AccountID = c.AccountID;
                childCase.ParentId = c.Id;
                
                listCasetobeCreated.add(childCase);
            }
        }
    }
    try{
        insert listCasetobeCreated;
    }catch(Exception e){System.debug('Insert error'+e.getMessage());}
    
}
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import fetchTestUpdateStatus from '@salesforce/apex/Hover.fetchTestUpdateStatus';


//set the fields we want to expose in lwc
const FIELDS = [
    'HOVER4SF__HOVER_Job__c.Name',
    'HOVER4SF__HOVER_Job__c.HOVER4SF__HOVER_Job_ID__c',
    'HOVER4SF__HOVER_Job__c.HOVER4SF__Assignee__c',
    'HOVER4SF__HOVER_Job__c.HOVER4SF__State__c'
];

export default class updateJobStatusButton extends LightningElement {
    @api recordId;

    //wire the class to the Apex class
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS  })
    job;

    disabled = false;


    handleClick(){
        console.log(this.job);
        if(this.job.data.fields.HOVER4SF__State__c.value == "complete"){
            this.disabled = true;
            alert("Job is already complete");
        }
          fetchTestUpdateStatus({ jobID: (this.job.data.fields.HOVER4SF__HOVER_Job_ID__c.value)})
              .then(response => {
                 console.log('request sent')
                 this.disabled = true;
              })
              .catch(error => {
                  console.log('Something went wrong')
                  
              });
            
    }
}

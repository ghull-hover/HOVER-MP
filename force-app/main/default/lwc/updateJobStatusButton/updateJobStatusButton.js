import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import fetchTestUpdateStatus from '@salesforce/apex/Hover.fetchTestUpdateStatus';


//set the fields we want to expose in lwc
const FIELDS = [
    'HOVER_Job__c.Name',
    'HOVER_Job__c.HOVER_Job_ID__c',
    'HOVER_Job__c.Assignee__c',
    'HOVER_Job__c.State__c'
];

export default class updateJobStatusButton extends LightningElement {
    @api recordId;

    //wire the class to the Apex class
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS  })
    job;

    disabled = false;


    handleClick(){
        if(this.job.data.fields.State__c.value == "complete"){
            this.disabled = true;
            alert("Job is already complete");
        }
          fetchTestUpdateStatus({ jobID: (this.job.data.fields.HOVER_Job_ID__c.value)})
              .then(response => {
                 console.log('request sent')
                 this.disabled = true;
              })
              .catch(error => {
                  console.log('Something went wrong')
                  
              });
            
    }
}
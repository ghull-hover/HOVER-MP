public with sharing class HoverRoofMeasurements {

    public class AreaTotalLengthDetail {
        public Integer area {get;set;}
        public  Integer total {get;set;}
        public  Decimal length {get;set;}
    }

    public class PitchDetail {
        public String roof_pitch {get;set;}
        public Integer area {get;set;}
        public Decimal percentage {get;set;}
    }

    public class WasteFactorDetail {
        public  Integer zero {get;set;}
        public  Integer plus_5_percent {get;set;}
        public  Integer plus_10_percent {get;set;}
        public  Integer plus_15_percent {get;set;}
        public  Integer plus_20_percent {get;set;}
        
    }

    public class WasteFactor {
        public  WasteFactorDetail area {get;set;}
    }

    public class HoverRoofMeasurementDetail {
        public AreaTotalLengthDetail roof_facets {get;set;}
        public AreaTotalLengthDetail ridges_hips {get;set;}
        public AreaTotalLengthDetail valleys {get;set;}
        public AreaTotalLengthDetail rakes {get;set;}
        public AreaTotalLengthDetail gutters_eaves {get;set;}
        public AreaTotalLengthDetail flashing {get;set;}
        public AreaTotalLengthDetail step_flashing {get;set;}
        public PitchDetail []pitch {get;set;}
        public WasteFactor waste_factor {get;set;}
    
    }

    public HoverRoofMeasurementDetail roof {get;set;}

    public HoverRoofMeasurements() {
        

    }
}
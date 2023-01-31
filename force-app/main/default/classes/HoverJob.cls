public class HoverJob {
    public String name {get; set;}
    public String location_line_1 {get; set;}
    public String location_line_2 {get; set;}
    public String location_city {get; set;}
    public String location_region {get; set;}
    public String location_postal_code {get; set;}
    public String location_country {get; set;}
    public Integer deliverable_id {get; set;}
    public String customer_email {get; set;}
    public String customer_phone {get; set;}
    public String id {get; set;}
    public String external_identifier {get; set;}
    public String hover_user_id {get; set;}
    public String wallet_id {get; set;}
    
    
    public HoverJob (String pname, String plocation_line_1, String pid, String pexternal_identifier) {
        name = pname;
        location_line_1 = plocation_line_1;
        id = pid;
        external_identifier = pexternal_identifier;
    }
    public HoverJob () {
    }
    
}
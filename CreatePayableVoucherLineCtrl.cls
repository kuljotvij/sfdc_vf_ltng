public class CreatePayableVoucherLineCtrl {
    
    public String accId                                                         { get; set; }
    public Map<Id, Payable_Voucher__c> mapPVIdToPV;
    public Map<Id, Payable_Voucher_Line__c> mapPVLIdToPVL;
    public Map<Id, List<Payable_Voucher_Line__c>> mapPVIdToPVL                  { get; set; }
    public String payableVoucherId                                              { get; set; }
    public String payableVoucherLineId                                          { get; set; }
    public Payable_Voucher__c payableVoucher                                    { get; set; }
    public Payable_Voucher_Line__c payableVoucherLine                           { get; set; }
    public List<Payable_Voucher_Line__c> lstPayableVoucherLine                  { get; set; }
    
    public CreatePayableVoucherLineCtrl(ApexPages.standardController stdCtrl){
        this.accId = stdCtrl.getId();
        this.payableVoucher = new Payable_Voucher__c( Vendor__c = accId );
        this.mapPVIdToPV = new Map<Id, Payable_Voucher__c>();
        this.lstPayableVoucherLine = new List<Payable_Voucher_Line__c>();
    }
    public CreatePayableVoucherLineCtrl(){}
    
    public List<Payable_Voucher__c> getPayableVouchers() { 
        mapPVIdToPV = new Map<Id, Payable_Voucher__c>();
        mapPVIdToPVL = new Map<Id, List<Payable_Voucher_Line__c>>();
        mapPVLIdToPVL = new Map<Id, Payable_Voucher_Line__c>();
        for(Payable_Voucher__c pv : [SELECT Name, 
                                            Vendor__r.Name,
                                            Approved__c,
                                            Payable_Invoice__r.Name,
                                            Vendor_Invoice_Number__c,
                                            Owner__c,
                                            Payable_Invoice_Created__c,
                                            Event__c, 
                                            Program__c,
                                            Focus_Area__c,
                                            Publication__c, 
                                            Voucher_Date__c,
                                            Team__c,
                                            Voucher_Description__c,
                                           (SELECT Name, 
                                                   Payable_Voucher__c,
                                                   Expense_GLA__c,
                                                   Income_Type_1042__c,
                                                   Mercatus_Center_Expense__c,
                                                   Mercatus_Center_Value__c,
                                                   Payable_Invoice_Expense_Line_Item__c,
                                                   Value__c,
                                                   Voucher_Line_Des__c
                                              FROM Payable_Voucher_Lines__r
                                          ORDER BY Name)
                                       FROM Payable_Voucher__c
                                      WHERE Vendor__c =: accId
                                   ORDER BY Name]){
            this.mapPVIdToPV.put( pv.Id, pv );
            for(Payable_Voucher_Line__c pvl : pv.Payable_Voucher_Lines__r){
                this.mapPVLIdToPVL.put( pvl.Id, pvl );
                
                if(mapPVIdToPVL.containsKey(pv.Id)){
                    this.mapPVIdToPVL.get(pv.Id).add( pvl );
                }else{
                    this.mapPVIdToPVL.put( pv.Id, new List<Payable_Voucher_Line__c>{ pvl } );
                }
                
            }
        }
        return mapPVIdToPV.values();
    }
    
    public Integer getPayableVoucherLen() {
        return getPayableVouchers().size();
    }
    
    public pagereference createPV() {
        
        upsert payableVoucher;
        
        this.payableVoucherLine = new Payable_Voucher_Line__c();
        this.payableVoucherLine.Payable_Voucher__c = payableVoucher.Id;
        this.mapPVIdToPV.put( payableVoucher.Id, payableVoucher );
        
        return null;
    }
    
    public pagereference editPV() {
        this.payableVoucher = mapPVIdToPV.get( payableVoucherId );
        
        this.payableVoucherLine = new Payable_Voucher_Line__c();
        this.payableVoucherLine.Payable_Voucher__c = payableVoucherId;
        
        for(Payable_Voucher_Line__c pvl : mapPVLIdToPVL.values()){
            if(pvl.Payable_Voucher__c == payableVoucherId)
                this.lstPayableVoucherLine.add(pvl);
        }
        
        return null;
    }
    
    public pagereference editPVL() {
        this.payableVoucherLine = mapPVLIdToPVL.get( payableVoucherLineId );
        return null;
    }
    
    public pagereference createPVL() {
        upsert lstPayableVoucherLine;
        
        for(Payable_Voucher_Line__c pvl : lstPayableVoucherLine){
            this.mapPVLIdToPVL.put( pvl.Id, pvl );
        }
        
        this.lstPayableVoucherLine = new List<Payable_Voucher_Line__c>();
        this.mapPVIdToPVL = new Map<Id, List<Payable_Voucher_Line__c>>();
        this.payableVoucher = new Payable_Voucher__c( Vendor__c = accId );
        
        return null;
    }
    
    public PageReference del() {
        
        if( String.isNotBlank(payableVoucherId) && mapPVIdToPV.containsKey(payableVoucherId) ){
            delete mapPVIdToPV.get(payableVoucherId);
        }
        if( String.isNotBlank(payableVoucherLineId) && mapPVLIdToPVL.containsKey(payableVoucherLineId) ){
            delete mapPVLIdToPVL.get(payableVoucherLineId);
        }
        return null;
    }
    
    public pagereference cancelPV() {
        this.lstPayableVoucherLine = new List<Payable_Voucher_Line__c>();
        this.payableVoucher = new Payable_Voucher__c( Vendor__c = accId );
        return null;
    }
    
    public pagereference cancelPVL() {
        this.payableVoucherLineId = null;
        this.payableVoucherLine = new Payable_Voucher_Line__c();
        this.payableVoucherLine.Payable_Voucher__c = payableVoucherId;
        return null;
    }
    
    public void savePVL(){
        for(Payable_Voucher_Line__c pvl : mapPVIdToPVL.get(payableVoucherLine.Payable_Voucher__c)){
            if(pvl.Id == payableVoucherLine.Id){
                Integer i = mapPVIdToPVL.get(payableVoucherLine.Payable_Voucher__c).indexOf(pvl);
                mapPVIdToPVL.get(payableVoucherLine.Payable_Voucher__c).set( i, payableVoucherLine );
                lstPayableVoucherLine.set( i, payableVoucherLine );
            }
        }
        
        this.payableVoucherLineId = null;
        this.payableVoucherLine = new Payable_Voucher_Line__c();
        this.payableVoucherLine.Payable_Voucher__c = payableVoucherId;
    }

    public void addPVL(){
        this.lstPayableVoucherLine.add( payableVoucherLine );
        this.payableVoucherLine = new Payable_Voucher_Line__c( Name = '', Payable_Voucher__c = payableVoucher.Id );
    }
}
#if not CLEAN22
codeunit 161011 "Create Vendor Pmt. Address"
{
    ObsoleteReason = 'Address is taken from the fields Pay-to Address, Pay-to City, etc.';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';

    trigger OnRun()
    begin
        InsertData('40000', XCENTRAL, XPurchaseDiscount, XCentralPolygon, XBarcelona, XES08036, XJuanBachs);
    end;

    var
        VendPayAdr: Record "Vendor Pmt. Address";
        XCENTRAL: Label 'CENTRAL';
        XPurchaseDiscount: Label 'Purchase Discount';
        XCentralPolygon: Label 'Central Polygon';
        XBarcelona: Label 'Barcelona';
        XES08036: Label 'ES-08036';
        XJuanBachs: Label 'Juan Bachs';
        CreatePostCode: Codeunit "Create Post Code";

    procedure InsertData("Vendor No.": Code[20]; "Code": Code[10]; Name: Text[50]; Address: Text[50]; City: Text[30]; "Post Code": Code[20]; Contact: Text[30])
    begin
        VendPayAdr.Init();
        VendPayAdr.Validate("Vendor No.", "Vendor No.");
        VendPayAdr.Validate(Code, Code);
        VendPayAdr.Validate(Name, Name);
        VendPayAdr.Validate(Address, Address);
        VendPayAdr."Post Code" := CreatePostCode.FindPostCode("Post Code");
        VendPayAdr.City := City;
        VendPayAdr.Validate(Contact, Contact);
        VendPayAdr.Insert();
    end;
}


#endif
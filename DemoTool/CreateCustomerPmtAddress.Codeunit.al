#if not CLEAN22
codeunit 161010 "Create Customer Pmt. Address"
{
    ObsoleteReason = 'Address is taken from the fields Bill-to Address, Bill-to City, etc.';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';

    trigger OnRun()
    begin
        InsertData('40000', XCENTRAL, XSalesDiscount, XCentralPolygon, XBarcelona, XES08036, XJuanBachs);
    end;

    var
        CustPayAdr: Record "Customer Pmt. Address";
        XCENTRAL: Label 'CENTRAL';
        XSalesDiscount: Label 'Sales Discount';
        XCentralPolygon: Label 'Central Polygon';
        XBarcelona: Label 'Barcelona';
        XES08036: Label 'ES-08036';
        XJuanBachs: Label 'Juan Bachs';
        CreatePostCode: Codeunit "Create Post Code";

    procedure InsertData("Customer No.": Code[20]; "Code": Code[10]; Name: Text[50]; Address: Text[50]; City: Text[30]; "Post Code": Code[20]; Contact: Text[30])
    begin
        CustPayAdr.Init();
        CustPayAdr.Validate("Customer No.", "Customer No.");
        CustPayAdr.Validate(Code, Code);
        CustPayAdr.Validate(Name, Name);
        CustPayAdr.Validate(Address, Address);
        CustPayAdr."Post Code" := CreatePostCode.FindPostCode("Post Code");
        CustPayAdr.City := City;
        CustPayAdr.Validate(Contact, Contact);
        CustPayAdr.Insert();
    end;
}


#endif
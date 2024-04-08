#if not CLEAN21
codeunit 101020 "Create Sales Discount"
{
    ObsoleteState = Pending;
    ObsoleteTag = '19.0';
    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(SalesLineDisc."Sales Type"::"Customer Disc. Group", RetailCode, FinishedCode, 0, 10);
            InsertData(SalesLineDisc."Sales Type"::"Customer Disc. Group", RetailCode, RawMatCode, 0, 15);
            InsertData(SalesLineDisc."Sales Type"::"Customer Disc. Group", XLARGEACC, FinishedCode, 0, 15);
            InsertData(SalesLineDisc."Sales Type"::"Customer Disc. Group", XLARGEACC, RawMatCode, 0, 20);
            InsertData(SalesLineDisc."Sales Type"::"Customer Disc. Group", XLARGEACC, ResaleCode, 0, 5);
            InsertData(SalesLineDisc."Sales Type"::"All Customers", '', XA, 5, 15);
            InsertData(SalesLineDisc."Sales Type"::"All Customers", '', XA, 15, 25);
            InsertData(SalesLineDisc."Sales Type"::"All Customers", '', XB, 25, 15);
            InsertData(SalesLineDisc."Sales Type"::"All Customers", '', XB, 100, 25);
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        SalesLineDisc: Record "Sales Line Discount";
        XLARGEACC: Label 'LARGE ACC';
        XA: Label 'A';
        XB: Label 'B';

    procedure InsertData("Sales Type": Option; "Sales Code": Code[30]; "Item Discount Group": Code[10]; "Minimum Quantity": Decimal; "Discount %": Decimal)
    begin
        SalesLineDisc.Init();
        SalesLineDisc.Validate("Sales Type", "Sales Type");
        SalesLineDisc.Validate("Sales Code", "Sales Code");
        SalesLineDisc.Validate(Type, SalesLineDisc.Type::"Item Disc. Group");
        SalesLineDisc.Validate(Code, "Item Discount Group");
        SalesLineDisc.Validate("Minimum Quantity", "Minimum Quantity");
        SalesLineDisc.Validate("Line Discount %", "Discount %");
        SalesLineDisc.Insert(true);
    end;
}
#endif

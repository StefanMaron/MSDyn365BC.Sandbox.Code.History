codeunit 119044 "Modify Sales & Rec. Setup"
{

    trigger OnRun()
    begin
        with "Sales & Receivables Setup" do begin
            Get();
            "Create No. Series".InitFinalSeries("Order Nos.", XSORDM, XSalesOrderManufacturing, 9);
            "Order Nos." := XSORDM;
            Modify();
        end;
    end;

    var
        "Sales & Receivables Setup": Record "Sales & Receivables Setup";
        "Create No. Series": Codeunit "Create No. Series";
        XSORDM: Label 'S-ORD-M';
        XSalesOrderManufacturing: Label 'Sales Order (Manufacturing)';
        XSORD1: Label 'S-ORD-1';

    procedure Finalize()
    begin
        with "Sales & Receivables Setup" do begin
            Get();
            "Order Nos." := XSORD1;
            Modify();
        end;
    end;
}


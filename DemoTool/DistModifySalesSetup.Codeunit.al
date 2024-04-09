codeunit 118811 "Dist. Modify Sales Setup"
{

    trigger OnRun()
    var
        "No. Series": Record "No. Series";
    begin
        with "Sales & Receivables Setup" do begin
            Get();
            "Create No. Series".InitTempSeries("Order Nos.", XSORDD, XSalesOrderDist, 6,
              "No. Series"."No. Series Type"::Normal, '', 0, '', false);
            "Order Nos." := XSORDD;
            Modify();
        end;
    end;

    var
        "Sales & Receivables Setup": Record "Sales & Receivables Setup";
        "Create No. Series": Codeunit "Create No. Series";
        XSORDD: Label 'S-ORD-D';
        XSalesOrderDist: Label 'Sales Order (Dist)';
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


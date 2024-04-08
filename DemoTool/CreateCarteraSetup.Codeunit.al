codeunit 161012 "Create Cartera Setup"
{

    trigger OnRun()
    begin
        with "Cartera Setup" do begin
            Get();
            "Bills Discount Limit Warnings" := true;
            "Cartera Setup"."CCC Ctrl Digits Check String" := X63791058421;
            "Create No. Series".InitFinalSeries("Bill Group Nos.", XBREM, XBillGroup, 6);
            "Create No. Series".InitFinalSeries("Payment Order Nos.", XBORDPAG, XPaymentOrder, 9);
            Modify();
            "Source Code Setup".Get();
            "Source Code Setup"."Cartera Journal" := XCARJNL;
            "Source Code Setup".Modify();
        end;
    end;

    var
        "Cartera Setup": Record "Cartera Setup";
        "Create No. Series": Codeunit "Create No. Series";
        "Source Code Setup": Record "Source Code Setup";
        X63791058421: Label '63791058421';
        XBREM: Label 'B-REM';
        XBillGroup: Label 'Bill Group';
        XBORDPAG: Label 'B-ORDPAG';
        XPaymentOrder: Label 'PaymentOrder';
        XESP: Label 'ESP';
        XCARJNL: Label 'CARJNL';

    procedure Finalize()
    begin
        with "Cartera Setup" do begin
            Get();
            "Bill Group Nos." := XBREM;
            "Payment Order Nos." := XBORDPAG;
            Modify();
        end;
    end;
}


codeunit 118870 "Create Assembly Setup"
{

    trigger OnRun()
    var
        "No. Series": Record "No. Series";
    begin
        with AssemblySetup do begin
            if not Get() then
                Insert();

            Validate("Stockout Warning", true);
            Validate("Copy Component Dimensions from", "Copy Component Dimensions from"::"Item/Resource Card");
            Validate("Copy Comments when Posting", true);
            Validate("Create Movements Automatically", true);

            CreateNoSeries.InitBaseSeries("Assembly Order Nos.", XAORD, XAORDName, '1', XEndingNumber, XLastNumberUsed, XWarningNumber, 1,
              "No. Series"."No. Series Type"::Normal, '', 0, '', false, true);//IT
            CreateNoSeries.InitBaseSeries("Assembly Quote Nos.", XAQUO, XAQuoteName, '1', XEndingNumber, XLastNumberUsed, XWarningNumber, 1,
              "No. Series"."No. Series Type"::Normal, '', 0, '', false, true);//IT
            CreateNoSeries.InitBaseSeries("Blanket Assembly Order Nos.", XABLK, XABLKName, '1', XEndingNumber, XLastNumberUsed, XWarningNumber, 1,
              "No. Series"."No. Series Type"::Normal, '', 0, '', false, true);//IT
            CreateNoSeries.InitBaseSeries("Posted Assembly Order Nos.", XAORDPlus, XAORDPlusName, '1', XEndingNumber, XLastNumberUsed, XWarningNumber, 1,
              "No. Series"."No. Series Type"::Normal, '', 0, '', false, true);//IT
            "Assembly Order Nos." := XAORD;
            "Assembly Quote Nos." := XAQUO;
            "Blanket Assembly Order Nos." := XABLK;
            "Posted Assembly Order Nos." := XAORDPlus;

            Modify();
        end;
    end;

    var
        AssemblySetup: Record "Assembly Setup";
        CreateNoSeries: Codeunit "Create No. Series";
        XAORD: Label 'A-ORD', Comment = 'A_ORD stands for Assembly-Order';
        XAORDName: Label 'Assembly Orders';
        XAQUO: Label 'A-QUO', Comment = 'A-QUO stands for Assembly-Quote.';
        XAQuoteName: Label 'Assembly Quote';
        XABLK: Label 'A-BLK', Comment = 'A-BLK stands for Assembly-Blanket.';
        XABLKName: Label 'Blanket Assembly Orders';
        XAORDPlus: Label 'A-ORD+';
        XAORDPlusName: Label 'Posted Assembly Orders';
        XEndingNumber: Label 'A01000', Comment = 'A stands for Assembly.';
        XLastNumberUsed: Label 'A00000', Comment = 'A stands for Assembly.';
        XWarningNumber: Label 'A00995', Comment = 'A stands for Assembly.';
}


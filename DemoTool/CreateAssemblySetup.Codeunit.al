codeunit 118870 "Create Assembly Setup"
{

    trigger OnRun()
    begin
        with AssemblySetup do begin
            if not Get() then
                Insert();

            Validate("Stockout Warning", true);
            Validate("Copy Component Dimensions from", "Copy Component Dimensions from"::"Item/Resource Card");
            Validate("Copy Comments when Posting", true);
            Validate("Create Movements Automatically", true);
            Validate("Default Gen.Bus.Post. Grp. CZA", DemoDataSetup.IAssemblyCode()); // NAVCZ

            CreateNoSeries.InitBaseSeries("Assembly Order Nos.", XAORD, XAORDName, '1', XEndingNumber, XLastNumberUsed, XWarningNumber, 1, true);
            CreateNoSeries.InitBaseSeries("Assembly Quote Nos.", XAQUO, XAQuoteName, '1', XEndingNumber, XLastNumberUsed, XWarningNumber, 1, true);
            CreateNoSeries.InitBaseSeries("Blanket Assembly Order Nos.", XABLK, XABLKName, '1', XEndingNumber,
              XLastNumberUsed, XWarningNumber, 1, true);
            CreateNoSeries.InitBaseSeries("Posted Assembly Order Nos.", XAORDPlus, XAORDPlusName, '1', XEndingNumber,
              XLastNumberUsed, XWarningNumber, 1, true);
            "Assembly Order Nos." := XAORD;
            "Assembly Quote Nos." := XAQUO;
            "Blanket Assembly Order Nos." := XABLK;
            "Posted Assembly Order Nos." := XAORDPlus;

            Modify();
        end;
    end;

    var
        AssemblySetup: Record "Assembly Setup";
        DemoDataSetup: Record "Demo Data Setup";
        CreateNoSeries: Codeunit "Create No. Series";
        XAORD: Label 'A-ORD', Comment = 'A-ORD stands for Assembly-Order';
        XAORDName: Label 'Assembly Orders';
        XAQUO: Label 'A-QUO', Comment = 'A-ORD stands for Assembly-Quote.';
        XAQuoteName: Label 'Assembly Quote';
        XABLK: Label 'A-BLK', Comment = 'A_BLK stands for Assembly-Blanket.';
        XABLKName: Label 'Assembly Blanket Orders';
        XAORDPlus: Label 'A-ORD+';
        XAORDPlusName: Label 'Posted Assembly Orders';
        XEndingNumber: Label 'A01000', Comment = 'A stands for Assembly.';
        XLastNumberUsed: Label 'A00000', Comment = 'A stands for Assemby.';
        XWarningNumber: Label 'A00995', Comment = 'A stands for Assembly.';
}


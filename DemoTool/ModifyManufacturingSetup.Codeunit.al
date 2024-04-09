codeunit 119070 "Modify Manufacturing Setup"
{

    trigger OnRun()
    var
        "No. Series": Record "No. Series";
    begin
        DemoDataSetup.Get();
        MfgSetup.Get();
        CreateNoSeries.InitFinalSeries(
          MfgSetup."Planned Order Nos.", XMPLANM, XProductionOrderPlanned, 9,
          "No. Series"."No. Series Type"::Normal, '', 0, '', false);
        MfgSetup."Planned Order Nos." := XMPLANM;

        CreateNoSeries.InitFinalSeries(
          MfgSetup."Firm Planned Order Nos.", XMFIRMPM, XProductionOrderFirmPlanned, 10,
          "No. Series"."No. Series Type"::Normal, '', 0, '', false);
        MfgSetup."Firm Planned Order Nos." := XMFIRMPM;

        CreateNoSeries.InitFinalSeries(
          MfgSetup."Released Order Nos.", XMRELM, XProductionOrderReleased, 11,
          "No. Series"."No. Series Type"::Normal, '', 0, '', false);
        MfgSetup."Released Order Nos." := XMRELM;

        MfgSetup."Current Production Forecast" := Format(DemoDataSetup."Starting Year" + 1);
        MfgSetup."Show Capacity In" := XMINUTES;
        MfgSetup.Modify();
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        MfgSetup: Record "Manufacturing Setup";
        CreateNoSeries: Codeunit "Create No. Series";
        XMPLANM: Label 'M-PLAN-M';
        XMRELM: Label 'M-REL-M';
        XProductionOrderPlanned: Label 'Production Order(Planned)';
        XProductionOrderFirmPlanned: Label 'Production Order(Firm Planned)';
        XProductionOrderReleased: Label 'Production Order(Released)';
        XMFIRMPM: Label 'M-FIRMP-M';
        XMPLAN: Label 'M-PLAN';
        XMFIRMP: Label 'M-FIRMP';
        XMREL: Label 'M-REL';
        XMINUTES: Label 'MINUTES', Comment = 'Minutes is a unit to show capacity in Manufacturing Setup.';

    procedure Finalize()
    begin
        MfgSetup.Get();

        MfgSetup."Planned Order Nos." := XMPLAN;
        MfgSetup."Firm Planned Order Nos." := XMFIRMP;
        MfgSetup."Released Order Nos." := XMREL;

        MfgSetup.Modify();
    end;
}


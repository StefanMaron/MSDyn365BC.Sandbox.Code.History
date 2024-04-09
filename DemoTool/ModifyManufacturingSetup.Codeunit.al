codeunit 119070 "Modify Manufacturing Setup"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        with MfgSetup do begin
            Get();
            CreateNoSeries.InitFinalSeries(
              "Planned Order Nos.", XMPLANM, XProductionOrderPlanned, 9);
            "Planned Order Nos." := XMPLANM;

            CreateNoSeries.InitFinalSeries(
              "Firm Planned Order Nos.", XMFIRMPM, XProductionOrderFirmPlanned, 10);
            "Firm Planned Order Nos." := XMFIRMPM;

            CreateNoSeries.InitFinalSeries(
              "Released Order Nos.", XMRELM, XProductionOrderReleased, 11);
            "Released Order Nos." := XMRELM;

            "Current Production Forecast" := Format(DemoDataSetup."Starting Year" + 1);
            "Show Capacity In" := XMINUTES;
            Modify();
        end;
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
        with MfgSetup do begin
            Get();

            "Planned Order Nos." := XMPLAN;
            "Firm Planned Order Nos." := XMFIRMP;
            "Released Order Nos." := XMREL;

            Modify();
        end;
    end;
}


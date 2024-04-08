codeunit 119020 "Create Manufacturing Setup"
{

    trigger OnRun()
    begin
        with MfgSetup do begin
            if not Get() then
                Insert();
            Validate("Normal Starting Time", 080000T);
            Validate("Normal Ending Time", 230000T);
            Validate("Doc. No. Is Prod. Order No.", true);

            Validate("Cost Incl. Setup", true);
            Validate("Planning Warning", true);
            Validate("Dynamic Low-Level Code", true);

            "Create No. Series".InitBaseSeries("Work Center Nos.", XWORKCTR, XWorkCenters, XW10, XW99990, '', '', 10, true);
            "Create No. Series".InitBaseSeries("Machine Center Nos.", XMACHCTR, XMachineCenters, XM10, XM99990, '', '', 10, true);
            "Create No. Series".InitBaseSeries("Production BOM Nos.", XPRODBOM, XProductionBOMs, XP10, XP99990, '', '', 10, true);
            "Create No. Series".InitBaseSeries("Routing Nos.", XROUTING, XRoutingslc, XR10, XR99990, '', '', 10, true);
            "Create No. Series".InitTempSeries("Simulated Order Nos.", XMQUO, XSalesQuote);
            "Create No. Series".InitFinalSeries("Planned Order Nos.", XMPLAN, XPlannedorders, 1);
            "Create No. Series".InitFinalSeries("Firm Planned Order Nos.", XMFIRMP, XFirmPlannedorders, 1);
            "Create No. Series".InitFinalSeries("Released Order Nos.", XMREL, XReleasedorders, 1);
            "Simulated Order Nos." := XMQUO;
            "Planned Order Nos." := XMPLAN;
            "Firm Planned Order Nos." := XMFIRMP;
            "Released Order Nos." := XMREL;
            "Combined MPS/MRP Calculation" := true;
            Evaluate("Default Safety Lead Time", '<1D>');
            Modify();
        end;
    end;

    var
        MfgSetup: Record "Manufacturing Setup";
        "Create No. Series": Codeunit "Create No. Series";
        XWORKCTR: Label 'WORKCTR';
        XWorkCenters: Label 'Work Centers';
        XW10: Label 'W10';
        XW99990: Label 'W99990';
        XMACHCTR: Label 'MACHCTR';
        XMachineCenters: Label 'Machine Centers';
        XM10: Label 'M10';
        XM99990: Label 'M99990';
        XPRODBOM: Label 'PRODBOM';
        XProductionBOMs: Label 'Production BOMs';
        XP10: Label 'P10';
        XP99990: Label 'P99990';
        XROUTING: Label 'ROUTING';
        XRoutingslc: Label 'Routings';
        XR10: Label 'R10';
        XR99990: Label 'R99990';
        XMQUO: Label 'M-QUO';
        XSalesQuote: Label 'Sales Quote';
        XMPLAN: Label 'M-PLAN';
        XPlannedorders: Label 'Planned orders';
        XMFIRMP: Label 'M-FIRMP';
        XFirmPlannedorders: Label 'Firm Planned orders';
        XMREL: Label 'M-REL';
        XReleasedorders: Label 'Released orders';
}


codeunit 101315 "Create Jobs Setup"
{

    trigger OnRun()
    begin
        with JobsSetup do begin
            Get();
            if "Job Nos." = '' then
                if not NoSeries.Get(XJOBTxt) then
                    CreateNoSeries.InitBaseSeries("Job Nos.", XJOBTxt, XJOBTxt, XJ10Txt, XJ99990Txt, '', '', 10, true)
                else
                    "Job Nos." := XJOBTxt;
            if "Job WIP Nos." = '' then
                if not NoSeries.Get(XJOBWIPTxt) then
                    CreateNoSeries.InitBaseSeries("Job WIP Nos.", XJOBWIPTxt, XJobWIPDescTxt, XDefaultJobWIPNoTxt, XDefaultJobWIPEndNoTxt, '', '', 1, true)
                else
                    "Job WIP Nos." := XJOBWIPTxt;
            if "Price List Nos." = '' then
                if not NoSeries.Get(XJPL) then
                    CreateNoSeries.InitBaseSeries("Price List Nos.", XJPL, XJobPriceList, XJ00001, XJ99999, '', '', 1, true)
                else
                    "Price List Nos." := XJPL;
            Modify();
        end
    end;

    var
        JobsSetup: Record "Jobs Setup";
        NoSeries: Record "No. Series";
        CreateNoSeries: Codeunit "Create No. Series";
        XJOBTxt: Label 'JOB';
        XJ10Txt: Label 'J10';
        XJ99990Txt: Label 'J99990';
        XJOBWIPTxt: Label 'JOB-WIP', Comment = 'Cashflow is a name of Cash Flow Forecast No. Series.';
        XJPL: Label 'J-PL';
        XJobPriceList: Label 'Job Price List';
        XJ00001: Label 'J00001';
        XJ99999: Label 'J99999';
        XDefaultJobWIPNoTxt: Label 'WIP0000001', Comment = 'CF stands for Cash Flow.';
        XDefaultJobWIPEndNoTxt: Label 'WIP9999999';
        XJobWIPDescTxt: Label 'Job-WIP';
}


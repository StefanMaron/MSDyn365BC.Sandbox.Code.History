codeunit 101221 "Create No Series SaaS"
{

    trigger OnRun()
    var
        JJnlNoSeries: Code[20];
    begin
        with DummyJobsSetup do begin
            if not NoSeries.Get(XJOBTxt) then
                CreateNoSeries.InitBaseSeries("Job Nos.", XJOBTxt, XJOBTxt, XJ10Txt, XJ99990Txt, '', '', 10, true);

            if not NoSeries.Get(XJOBWIPTxt) then
                CreateNoSeries.InitBaseSeries("Job WIP Nos.", XJOBWIPTxt, XJobWIPDescTxt, XDefaultJobWIPNoTxt, XDefaultJobWIPEndNoTxt, '', '', 1, true);
        end;

        JJnlNoSeries := '';
        if not NoSeries.Get(XJJNL) then
            CreateNoSeries.InitBaseSeries(JJnlNoSeries, XJJNL, XJJNLDescTxt, XJJNLNoTxt, XJJNLEndNoTxt, '', '', 1, true);

        with DummyResourcesSetup do begin
            if not NoSeries.Get(XRES) then
                CreateNoSeries.InitBaseSeries("Resource Nos.", XRES, XRESDescTxt, XRESNoTxt, XResEndNoTxt, '', '', 10, true);

            if not NoSeries.Get(XTS) then
                CreateNoSeries.InitBaseSeries("Time Sheet Nos.", XTS, XTSDescTxt, XTSNoTxt, XTSEndNoTxt, '', '', 1, true);
        end;
    end;

    var
        DummyJobsSetup: Record "Jobs Setup";
        DummyResourcesSetup: Record "Resources Setup";
        NoSeries: Record "No. Series";
        CreateNoSeries: Codeunit "Create No. Series";
        XJOBTxt: Label 'JOB';
        XJ10Txt: Label 'J10';
        XJ99990Txt: Label 'J99990';
        XJOBWIPTxt: Label 'JOB-WIP', Comment = 'Cashflow is a name of Cash Flow Forecast No. Series.';
        XDefaultJobWIPNoTxt: Label 'WIP0000001', Comment = 'CF stands for Cash Flow.';
        XDefaultJobWIPEndNoTxt: Label 'WIP9999999';
        XJobWIPDescTxt: Label 'Job-WIP';
        XRES: Label 'RES';
        XRESDescTxt: Label 'Resource';
        XRESNoTxt: Label 'R0010';
        XResEndNoTxt: Label 'R9990';
        XTS: Label 'TS';
        XTSDescTxt: Label 'Time Sheet';
        XTSNoTxt: Label 'TS00001';
        XTSEndNoTxt: Label 'TS99999';
        XJJNL: Label 'JJNL-GEN';
        XJJNLDescTxt: Label 'Job Journal';
        XJJNLNoTxt: Label 'J00001';
        XJJNLEndNoTxt: Label 'J01000';
}


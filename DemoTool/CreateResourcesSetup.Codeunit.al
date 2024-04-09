codeunit 101314 "Create Resources Setup"
{

    trigger OnRun()
    begin
        with ResourcesSetup do begin
            Get();
            if "Resource Nos." = '' then
                if not NoSeries.Get(XRES) then
                    CreateNoSeries.InitBaseSeries("Resource Nos.", XRES, XResource, XR10, XR9990, '', '', 10, true)
                else
                    "Resource Nos." := XRES;
            if "Time Sheet Nos." = '' then
                if not NoSeries.Get(XTS) then
                    CreateNoSeries.InitBaseSeries("Time Sheet Nos.", XTS, XTimeSheet, XTS00001, XTS99999, '', '', 1, true)
                else
                    "Time Sheet Nos." := XTS;
#if not CLEAN22
            "Use New Time Sheet Experience" := true;
#endif
            Modify();
        end;
    end;

    var
        ResourcesSetup: Record "Resources Setup";
        NoSeries: Record "No. Series";
        CreateNoSeries: Codeunit "Create No. Series";
        XRES: Label 'RES';
        XResource: Label 'Resource';
        XR10: Label 'R10';
        XR9990: Label 'R9990';
        XTS: Label 'TS';
        XTimeSheet: Label 'Time Sheet';
        XTS00001: Label 'TS00001', Comment = 'TS stands for Time Sheet.';
        XTS99999: Label 'TS99999', Comment = 'TS stands for Time Sheet.';
}


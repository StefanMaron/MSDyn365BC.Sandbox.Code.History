codeunit 101899 "Create Demo Data from Config"
{

    trigger OnRun()
    begin
        if ErrorMsgMgt.IsActive() then
            CreateDemoData()
        else
            CreateDemoDataLogToFile(LogFileNameTxt);
    end;

    var
        ErrorMsgMgt: codeunit "Error Message Management";
        LogFileNameTxt: label 'CreateDemoData.log', Locked = true;

    local procedure CreateDemoData()
    var
        DemoDataSetup: Record "Demo Data Setup";
    begin
        SetupDemonstrationData(DemoDataSetup);
        CODEUNIT.Run(CODEUNIT::"Create Demonstration Data");
        CleanUp;
    end;

    local procedure CreateDemoDataLogToFile(LogFileName: Text) Success: Boolean;
    var
        ErrorMsgHandler: Codeunit "Error Message Handler";
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorCallStack: Text;
        ErrorText: Text;
    begin
        ErrorMsgMgt.Activate(ErrorMsgHandler);
        ErrorMsgMgt.PushContext(ErrorContextElement, Database::"Demo Data Setup", 0, 'COD101899 "Create Demo Data from Config"');
        Success := Codeunit.Run(Codeunit::"Create Demo Data from Config");
        if not Success then begin
            ErrorCallStack := GetLastErrorCallStack();
            ErrorText := GetLastErrorText();
        end;
        // WriteMessagesToFile() re-throws the last error, 
        // but we have to re-throw it from cod101899 context to be handled by NavRTC_Call in build scripts
        ErrorMsgHandler.WriteMessagesToFile(LogFileName, not Success);
        if not Success then
            error('%1 %2', ErrorText, ErrorCallStack);
    end;

    procedure SetupDemonstrationData(var DemoDataSetup: Record "Demo Data Setup")
    var
        DemoDataTool: Page "Demonstration Data Tool";
    begin
        with DemoDataSetup do begin
            if Get() then
                Delete();
            ImportDemoDataConfig;
            Get();
            if "Data Type" = "Data Type"::Evaluation then
                "Starting Year" := Date2DMY(Today, 3) - 1
            else
                "Starting Year" := Date2DMY(Today, 3) + 1;
            "Working Date" := DMY2Date(1, 1, "Starting Year");
            "Progress Window Design" := DemoDataTool.ProgressWindowDesign;
            "LCY an EMU Currency" := ("Currency Code" = 'EUR');
            SetTaxRates;
            Modify(true);
        end;
        UpdateDomains(DemoDataSetup);
    end;

    procedure CleanUp()
    var
        DemoDataSetup: Record "Demo Data Setup";
    begin
        DemoDataSetup.DeleteAll();
    end;

    procedure ImportDemoDataConfig()
    var
        DemoDataConfiguration: XMLport "Demo Data Configuration";
        ConfigFile: File;
        ConfigStream: InStream;
        CurrentLanguage: Integer;
    begin
        CurrentLanguage := GlobalLanguage;
        if DemoDataConfiguration.ConfigLanguageID <> CurrentLanguage then
            GlobalLanguage(DemoDataConfiguration.ConfigLanguageID);

        ConfigFile.Open(DemoDataConfiguration.ConfigFileName(false));
        ConfigFile.CreateInStream(ConfigStream);
        DemoDataConfiguration.SetSource(ConfigStream);
        DemoDataConfiguration.Import();
        ConfigFile.Close();

        if GlobalLanguage <> CurrentLanguage then
            GlobalLanguage(CurrentLanguage);
    end;

    procedure ExporttDemoDataConfig()
    var
        DemoDataConfiguration: XMLport "Demo Data Configuration";
        ConfigFile: File;
        ConfigStream: OutStream;
        CurrentLanguage: Integer;
    begin
        CurrentLanguage := GlobalLanguage;
        if DemoDataConfiguration.ConfigLanguageID <> CurrentLanguage then
            GlobalLanguage(DemoDataConfiguration.ConfigLanguageID);

        ConfigFile.Create(DemoDataConfiguration.ConfigFileName(false));
        ConfigFile.CreateOutStream(ConfigStream);
        DemoDataConfiguration.SetDestination(ConfigStream);
        DemoDataConfiguration.Export();
        ConfigFile.Close();

        if GlobalLanguage <> CurrentLanguage then
            GlobalLanguage(CurrentLanguage);
    end;

    local procedure UpdateDomains(var DemoDataSetup: Record "Demo Data Setup")
    begin
        with DemoDataSetup do
            if "Data Type" <> "Data Type"::Extended then begin
                SelectDomains(false);
                "Skip sequence of actions" := true;
                "Adjust for Payment Discount" := false;
                Modify();
            end;
    end;
}


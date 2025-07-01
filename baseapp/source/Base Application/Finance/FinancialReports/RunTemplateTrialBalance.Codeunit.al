#if not CLEAN25
namespace Microsoft.Finance.FinancialReports;

using System.Environment;
using System.Integration;
using System.Telemetry;

codeunit 580 "Run Template Trial Balance"
{
#pragma warning disable AS0072
    ObsoleteReason = 'Functionality replaced by "EXR Trial Balance Excel". Extend this report object with Excel layout instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '25.0';
#pragma warning restore AS0072

    trigger OnRun()
    var
        ODataUtility: Codeunit ODataUtility;
        ObjectTypeParam: Option ,,,,,,,,"Page","Query";
        StatementType: Option BalanceSheet,SummaryTrialBalance,CashFlowStatement,StatementOfRetainedEarnings,AgedAccountsReceivable,AgedAccountsPayable,IncomeStatement;
    begin
        LogUsageTelemetry();
        if not Confirm(DeprecatedMsg) then
            exit;
        if not (ClientTypeManagement.GetCurrentClientType() in [CLIENTTYPE::Phone, CLIENTTYPE::Tablet]) then
            ODataUtility.GenerateExcelTemplateWorkBook(ObjectTypeParam::Page, ServiceNameParmLbl, true,
              StatementType::SummaryTrialBalance)
        else begin
            Message(OfficeMobileMsg);
            exit;
        end;
    end;

    var
        ClientTypeManagement: Codeunit "Client Type Management";

        OfficeMobileMsg: Label 'Excel Reports cannot be opened in this environment because this version of Office does not support the file format.';
        DeprecatedMsg: Label 'This Excel report will be removed in an upcoming release, please use the report "Trial Balance (Preview)". Do you want to continue?';
        ServiceNameParmLbl: Label 'ExcelTemplateTrialBalance', Locked = true;
        
    local procedure LogUsageTelemetry()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('CodeunitId', Format(Codeunit::"Run Template Trial Balance", 0, 9));
        TelemetryDimensions.Add('ExcelTemplateName', ServiceNameParmLbl);
        FeatureTelemetry.LogUsage('0000ONX', 'Excel Template', 'Run Trial Balance Excel Report', TelemetryDimensions);
    end;
}

#endif
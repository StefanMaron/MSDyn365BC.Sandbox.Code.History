codeunit 101084 "Create Acc. Schedule Name"
{

    trigger OnRun()
    begin
        UpdateEvaluationDate();
        InsertData(XCAMPAIGN, XCampaignAnalysis, XBUDGANALYS, XCAMPAIGN);
        InsertData(XCASTAFF, XCostAcctPersonnelCosts, '', '');
        InsertData(XCATRANSFER, XCostAcctTransfer, '', '');
        InsertData(XCAPROF, XCostAcctSummaryRecordDB, '', '');

        // Modification Demo Finance (CM) : ajout des tableaux FR
        InsertData(XPROFIT, XIncomeStatementAccount, XPROFIT, '');
        InsertData(XSIG, XIntermediaryManagementCosts, '', '');

        // Modification Demo Finance (CM) : ajout des anciens tableaux Bilan/résultat
        InsertDataFR(XACTIVE, XActiveBalance, XGross, XProvDeprec, XNet, XAccountN1);
        InsertDataFR(XPASSIVE, XPassiveBalance, '', '', '', XAccountN1);
        InsertDataFR(XPROFIT, XIncomeStatementAccount, '', '', '', XAccountN1);
        InsertData(XDEGREE, XCalculationOfCashFlowRatio, XDEGREE, '');

        InsertData(XCASHFLOW, XCalculationOfCashFlow, XCASHFLOW, '');

        InsertData(XANALYSIS, XCapitalStructure, '', '');
        InsertData(XREVENUE, XRevenues, XBUDGANALYS, '');
    end;

    procedure InsertEvaluationData();
    begin
        InsertData(XANALYSIS, XCapitalStructure, XBALONLY, '');
        InsertData(XCASHFLOW, XCalculationOfCashFlow, XCASHFLOW, '');
        InsertData(XREVENUE, XRevenues, XBUDGANALYS, XREVENUE);
        InsertData(XACCCAT, XAccCatOverview, XPERIODS, '');
        InsertData(XBSDETTxt, XBalanceSheetDetailedTxt, CreateColumnLayoutName.GetBSTrendColumnLayoutName(), '');
        InsertData(XBSSUMTxt, XBalanceSheetSummarizedTxt, CreateColumnLayoutName.GetBSTrendColumnLayoutName(), '');
        InsertData(XISDETTxt, XIncomeStatementDetailedTxt, CreateColumnLayoutName.GetISTrendColumnLayoutName(), '');
        InsertData(XISSUMTxt, XIncomeStatementSummarizedTxt, CreateColumnLayoutName.GetISTrendColumnLayoutName(), '');
        InsertData(XTBTxt, XTrialBalanceTxt, CreateColumnLayoutName.GetBBDRCREBColumnLayoutName(), '');
    end;

    local procedure UpdateEvaluationDate();
    var
        AccScheduleName: Record "Acc. Schedule Name";
    begin
        if AccScheduleName.get(XREVENUE) then begin
            AccScheduleName.Validate("Analysis View Name", XREVENUE);
            AccScheduleName.Modify()
        end;
    end;

    var
        CreateColumnLayoutName: Codeunit "Create Column Layout Name";
        XANALYSIS: Label 'ANALYSIS';
        XBALONLY: Label 'BAL ONLY';
        XCapitalStructure: Label 'Capital Structure';
        XCAMPAIGN: Label 'CAMPAIGN';
        XCampaignAnalysis: Label 'Campaign Analysis';
        XBUDGANALYS: Label 'BUDGANALYS';
        XREVENUE: Label 'REVENUE';
        XRevenues: Label 'Revenues';
        XCASHFLOW: Label 'CASHFLOW', Comment = 'Cashflow is a name of Account Schedule.';
        XDEGREE: Label 'DEGREE', Comment = 'Degree is a name of Account Schedule.';
        XCalculationOfCashFlow: Label 'Calculation Of Cash Flow';
        XCalculationOfCashFlowRatio: Label 'Calculation of Cash Flow Ratio';
        XCASTAFF: Label 'CA-STAFF', Comment = 'Cost Acct. Personnel Costs.';
        XCostAcctPersonnelCosts: Label 'Cost Acct. Personnel Costs';
        XCATRANSFER: Label 'CA-TRANS', Comment = 'Cost Acct. Transfer.';
        XCostAcctTransfer: Label 'Cost Acct. Transfer';
        XCAPROF: Label 'CA-PROF', Comment = 'Cost Acct. Summary Record DB per CC/CO.';
        XCostAcctSummaryRecordDB: Label 'Cost Acct. Summary Record DB per CC/CO', Comment = 'It is description of Account Schedule Name. DB means Database, CC means Cost Center and CO means Cost Object.';
        XSIG: Label 'SIG';
        XProvDeprec: Label 'Prov. Deprec.';
        XNet: Label 'Net';
        XAccountN1: Label 'Account N-1';
        XGross: Label 'Gross';
        XIncomeStatementAccount: Label 'Income Statement Account';
        XIntermediaryManagementCosts: Label 'Intermediary Management Costs';
        XActiveBalance: Label 'Active Balance';
        XPassiveBalance: Label 'Passive Balance';
        XACTIVE: Label 'ACTIVE';
        XPASSIVE: Label 'PASSIVE';
        XPROFIT: Label 'PROFIT';
        XACCCAT: Label 'ACC-CAT', Comment = 'ACC-CAT is the name of the Account Schedule.';
        XAccCatOverview: Label 'Account Categories overview';
        XPERIODS: Label 'PERIODS';
        XBSDETTxt: Label 'BS DET', Locked = true;
        XBSSUMTxt: Label 'BS SUM', Locked = true;
        XISDETTxt: Label 'IS DET', Locked = true;
        XISSUMTxt: Label 'IS SUM', Locked = true;
        XTBTxt: Label 'TB', Locked = true;
        XBalanceSheetDetailedTxt: Label 'Balance Sheet Detailed';
        XBalanceSheetSummarizedTxt: Label 'Balance Sheet Summarized';
        XIncomeStatementDetailedTxt: Label 'Income Statement Detailed';
        XIncomeStatementSummarizedTxt: Label 'Income Statement Summarized';
        XTrialBalanceTxt: Label 'Trial Balance';

    procedure InsertData(Name: Code[10]; Description: Text[80]; DefaultColumnLayout: Code[10]; AnalysisViewName: Code[10])
    var
        FinancialReport: Record "Financial Report";
        "Acc. Schedule Name": Record "Acc. Schedule Name";
    begin
        "Acc. Schedule Name".Init();
        "Acc. Schedule Name".Validate(Name, Name);
        "Acc. Schedule Name".Validate(Description, Description);
#if not CLEAN22
        "Acc. Schedule Name"."Default Column Layout" := DefaultColumnLayout;
#endif
        "Acc. Schedule Name".Validate("Analysis View Name", AnalysisViewName);
        "Acc. Schedule Name".Insert();
        FinancialReport.Init();
        FinancialReport.Name := Name;
        FinancialReport."Financial Report Row Group" := Name;
        FinancialReport.Description := Description;
        FinancialReport."Financial Report Column Group" := DefaultColumnLayout;
        FinancialReport.Insert();
    end;

    procedure InsertDataFR(VarName: Code[10]; Description: Text[80]; "Net Change Title": Text[30]; "Net Change Title 2": Text[30]; "Net Changes Title": Text[30]; "Last Year Title": Text[30])
    var
        "Account Schedule Name": Record "FR Acc. Schedule Name";
    begin
        "Account Schedule Name".Init();
        "Account Schedule Name".Validate(Name, VarName);
        "Account Schedule Name".Validate(Description, Description);
        "Account Schedule Name".Validate("Caption Column 1", "Net Change Title");
        "Account Schedule Name".Validate("Caption Column 2", "Net Change Title 2");
        "Account Schedule Name".Validate("Caption Column 3", "Net Changes Title");
        "Account Schedule Name".Validate("Caption Column Previous Year", "Last Year Title");
        "Account Schedule Name".Insert();
    end;

    internal procedure GetBSDETAccountScheduleName(): Code[10]
    begin
        exit(CopyStr(XBSDETTxt, 1, 10));
    end;

    internal procedure GetBSSUMAccountScheduleName(): Code[10]
    begin
        exit(CopyStr(XBSSUMTxt, 1, 10));
    end;

    internal procedure GetISDETAccountScheduleName(): Code[10]
    begin
        exit(CopyStr(XISDETTxt, 1, 10));
    end;

    internal procedure GetISSUMAccountScheduleName(): Code[10]
    begin
        exit(CopyStr(XISSUMTxt, 1, 10));
    end;

    internal procedure GetTBAccountScheduleName(): Code[10]
    begin
        exit(CopyStr(XTBTxt, 1, 10));
    end;

}


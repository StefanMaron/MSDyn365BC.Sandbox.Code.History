codeunit 119100 "Create Chart Definitions"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        CreateFinancePerformanceCharts;
        ChartManagement.PopulateChartDefinitionTable;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        MakeAdjustments: Codeunit "Make Adjustments";
        CreateGLAccount: Codeunit "Create G/L Account";
        XCashCycleChartDescriptionTxt: Label 'Shows how many days money is tied up from the day you purchase inventory to the day you receive payment from customers.\\A cash cycle is calculated as: Days Sales in Inventory (DSI) + Days Sales Outstanding (DSO) - Days Payable Outstanding (DPO). ';
        XCashFlowChartDescriptionTxt: Label 'Shows the movement of money into or out of your company. You can select to view both future revenue and expenses not yet registered.\\Cash flow is calculated as follows: Receivables + Liquid Funds - Payables.';
        XIncomeAndExpenseChartDescriptionTxt: Label 'Shows the company''s trends in income over expenses. By comparing figures for different periods, you can detect periods that need further investigation.  ';
        XCashCycleAccSchedNameTxt: Label 'I_CACYCLE', Comment = 'Data for Cash Cycle chart abrivated. Starting with I beacuse of sorting. Maximum lenght 10 characters';
        XCashFlowAccSchedNameTxt: Label 'I_CASHFLOW', Comment = 'Data for Cash Flow chart abrivated. Starting with I beacuse of sorting. Maximum lenght 10 characters';
        XIncAndExpAccSchedNameTxt: Label 'I_INCEXP', Comment = 'Data for Income and Expense chart abrivated. Starting with I beacuse of sorting. Maximum lenght 10 characters';
        XReducedTrialBalanceAccSchedNameTxt: Label 'I_MINTRIAL', Comment = 'Data for Mini Trial Balance chart abrivated. Starting with I beacuse of sorting. Maximum lenght 10 characters';
        XAccSchedDescrTxt: Label 'Data for %1 Chart';
        XReducedTrialBalanceAccSchedDescriptionTxt: Label 'Data for Reduced Trial Balance Info Part';
        XPeriodsColumnLayoutNameTxt: Label 'PERIODS', Comment = 'Data for Mini Trial Balance chart abrivated. Starting with I beacuse of sorting. Maximum lenght 10 characters';
        XPeriodsColumnLayoutNameDescriptionTxt: Label 'Periods Definition for Mini Charts';
        XCurrentPeriodTxt: Label 'Current Period';
        XPeriodMinus1Txt: Label 'Current Period - 1';
        XPeriodMinus2Txt: Label 'Current Period - 2';
        XTotalReceivablesTxt: Label 'Total Receivables';
        XTotalPayablesTxt: Label 'Total Payables';
        XTotalCashFlowTxt: Label 'Total Cash Flow';
        XTotalLiquidFundsTxt: Label 'Total Liquid Funds';
        XTotalRevenueCreditTxt: Label 'Total Revenue (Credit)';
        XTotalRevenueTxt: Label 'Total Revenue';
        XTotalGoodsSoldTxt: Label 'Total Goods Sold';
        XTotalExternalCostsTxt: Label 'Total External Costs ';
        XTotalPersonnelCostsTxt: Label 'Total Personnel Costs';
        XTotalFADepricationTxt: Label 'Total Depr. on Fixed Assets';
        XOperatingExpensesTxt: Label 'Operating Expenses';
        XOtherExpensesTxt: Label 'Other Expenses';
        XTotalExpenditureTxt: Label 'Total Expenditure';
        XEarningsBeforeInterestTxt: Label 'Earnings Before Interest';
        XTotalInventoryTxt: Label 'Total Inventory';
        XDaysOfSalesOutstandingTxt: Label 'Days of Sales Outstanding';
        XDaysOfPaymentOutstandingTxt: Label 'Days of Payment Outstanding';
        XDaysSalesOfInventoryTxt: Label 'Days Sales of Inventory';
        XCashCycleDaysTxt: Label 'Cash Cycle (Days)';
        XTotalCostTxt: Label 'Total Cost';
        XGrossMarginTxt: Label 'Gross Margin';
        XGrossMarginPctTxt: Label 'Gross Margin %';
        XOperatingMarginTxt: Label 'Operating Margin';
        XOperatingMarginPctTxt: Label 'Operating Margin %';
        XIncomeBeforeInterestAndTaxTxt: Label 'Income before Interest and Tax';
        ChartManagement: Codeunit "Chart Management";

    local procedure CreateFinancePerformanceCharts()
    begin
        case DemoDataSetup."Data Type" of
            DemoDataSetup."Data Type"::Extended:
                SetupAccountSchedules;
            DemoDataSetup."Data Type"::Standard,
          DemoDataSetup."Data Type"::Evaluation:
                SetupAccountSchedulesForO365;
        end;
        CreateColumnLayout;
        InsertFinancialChartDefinitions;
    end;

    local procedure SetupAccountSchedules()
    var
        AccScheduleLine: Record "Acc. Schedule Line";
        BalanceAtDate: Option;
        NetChange: Option;
        TotalAccounts: Option;
        PostingAccounts: Option;
        Formula: Option;
    begin
        BalanceAtDate := AccScheduleLine."Row Type"::"Balance at Date";
        NetChange := AccScheduleLine."Row Type"::"Net Change";
        TotalAccounts := AccScheduleLine."Totaling Type"::"Total Accounts";
        PostingAccounts := AccScheduleLine."Totaling Type"::"Posting Accounts";
        Formula := AccScheduleLine."Totaling Type"::Formula;

        // Account Schedule for Cash Flow Chart
        CreateAccScheduleName(
          XCashFlowAccSchedNameTxt, StrSubstNo(XAccSchedDescrTxt, ChartManagement.CashFlowChartName), XPeriodsColumnLayoutNameTxt);
        CreateAccScheduleLine(
          XCashFlowAccSchedNameTxt, '10', XTotalReceivablesTxt, MakeAdjustments.Convert('992390'), TotalAccounts, BalanceAtDate);
        CreateAccScheduleLine(
          XCashFlowAccSchedNameTxt, '20', XTotalPayablesTxt, MakeAdjustments.Convert('995490'), TotalAccounts, BalanceAtDate);
        CreateAccScheduleLine(
          XCashFlowAccSchedNameTxt, '30', XTotalLiquidFundsTxt,
          StrSubstNo('%1|%2', MakeAdjustments.Convert('992990'), MakeAdjustments.Convert('995310')), TotalAccounts,
          BalanceAtDate);
        CreateAccScheduleLine(XCashFlowAccSchedNameTxt, '40', XTotalCashFlowTxt, '10..30', Formula, BalanceAtDate);

        // Account Schedule for Income and Expense Chart
        CreateAccScheduleName(
          XIncAndExpAccSchedNameTxt,
          StrSubstNo(XAccSchedDescrTxt, ChartManagement.IncomeAndExpenseChartName), XPeriodsColumnLayoutNameTxt);
        CreateAccScheduleLine(
          XIncAndExpAccSchedNameTxt, '10', XTotalRevenueCreditTxt, MakeAdjustments.Convert('996995'), TotalAccounts, NetChange);
        CreateAccScheduleLine(XIncAndExpAccSchedNameTxt, '11', XTotalRevenueTxt, '-10', Formula, NetChange);
        CreateAccScheduleLine(
          XIncAndExpAccSchedNameTxt, '20', XTotalGoodsSoldTxt, MakeAdjustments.Convert('997995'), TotalAccounts, NetChange);
        CreateAccScheduleLine(
          XIncAndExpAccSchedNameTxt, '30', XTotalExternalCostsTxt, MakeAdjustments.Convert('998695'), TotalAccounts, NetChange);
        CreateAccScheduleLine(
          XIncAndExpAccSchedNameTxt, '40', XTotalPersonnelCostsTxt, MakeAdjustments.Convert('998790'), TotalAccounts, NetChange);
        CreateAccScheduleLine(
          XIncAndExpAccSchedNameTxt, '50', XTotalFADepricationTxt, MakeAdjustments.Convert('998890'), TotalAccounts, NetChange);
        CreateAccScheduleLine(
          XIncAndExpAccSchedNameTxt, '60', XOtherExpensesTxt, MakeAdjustments.Convert('998910'), PostingAccounts, NetChange);
        CreateAccScheduleLine(XIncAndExpAccSchedNameTxt, '70', XTotalExpenditureTxt, '-20..60', Formula, NetChange);
        CreateAccScheduleLine(XIncAndExpAccSchedNameTxt, '80', XEarningsBeforeInterestTxt, '11+70', Formula, NetChange);

        // Account Schedule for Cash Cycle Chart
        CreateAccScheduleName(
          XCashCycleAccSchedNameTxt, StrSubstNo(XAccSchedDescrTxt, ChartManagement.CashCycleChartName), XPeriodsColumnLayoutNameTxt);
        CreateAccScheduleLine(
          XCashCycleAccSchedNameTxt, '10', XTotalRevenueTxt, MakeAdjustments.Convert('996995'), TotalAccounts, BalanceAtDate);
        CreateAccScheduleLine(
          XCashCycleAccSchedNameTxt, '20', XTotalReceivablesTxt, MakeAdjustments.Convert('992390'), TotalAccounts, BalanceAtDate);
        CreateAccScheduleLine(
          XCashCycleAccSchedNameTxt, '30', XTotalPayablesTxt, MakeAdjustments.Convert('995490'), TotalAccounts, NetChange);
        CreateAccScheduleLine(
          XCashCycleAccSchedNameTxt, '40', XTotalInventoryTxt, MakeAdjustments.Convert('992190'), TotalAccounts, NetChange);
        CreateAccScheduleLineFormula(XCashCycleAccSchedNameTxt, '100', XDaysOfSalesOutstandingTxt, '-360*''20''/''10''', Formula, BalanceAtDate);
        CreateAccScheduleLineFormula(XCashCycleAccSchedNameTxt, '110', XDaysOfPaymentOutstandingTxt, '360*''30''/''10''', Formula, BalanceAtDate);
        CreateAccScheduleLineFormula(XCashCycleAccSchedNameTxt, '120', XDaysSalesOfInventoryTxt, '-360*''40''/''10''', Formula, BalanceAtDate);
        CreateAccScheduleLineFormula(XCashCycleAccSchedNameTxt, '200', XCashCycleDaysTxt, '100+110-120', Formula, BalanceAtDate);

        // Account Schedule for Reduced Trial Balance
        CreateAccScheduleName(
          XReducedTrialBalanceAccSchedNameTxt, XReducedTrialBalanceAccSchedDescriptionTxt, XPeriodsColumnLayoutNameTxt);
        CreateAccScheduleLineExtended(
          XReducedTrialBalanceAccSchedNameTxt, '10', XTotalRevenueTxt, MakeAdjustments.Convert('996995'), TotalAccounts, NetChange, true);
        CreateAccScheduleLineExtended(
          XReducedTrialBalanceAccSchedNameTxt, '20', XTotalCostTxt, MakeAdjustments.Convert('997995'), TotalAccounts, NetChange, true);
        CreateAccScheduleLine(XReducedTrialBalanceAccSchedNameTxt, '30', XGrossMarginTxt, '-10-20', Formula, NetChange);
        CreateAccScheduleLineFormula(XReducedTrialBalanceAccSchedNameTxt, '40', XGrossMarginPctTxt, '-''30''/''10''*100', Formula, NetChange);
        CreateAccScheduleLine(
          XReducedTrialBalanceAccSchedNameTxt, '50', XOperatingExpensesTxt,
          StrSubstNo('%1|%2|%3', MakeAdjustments.Convert('998695'), MakeAdjustments.Convert('998790'), MakeAdjustments.Convert('998890')),
          TotalAccounts, NetChange);
        CreateAccScheduleLine(XReducedTrialBalanceAccSchedNameTxt, '60', XOperatingMarginTxt, '30 - 50', Formula, NetChange);
        CreateAccScheduleLineFormula(XReducedTrialBalanceAccSchedNameTxt, '70', XOperatingMarginPctTxt, '-''60''/''10''*100', Formula, NetChange);
        CreateAccScheduleLine(
          XReducedTrialBalanceAccSchedNameTxt, '80', XOtherExpensesTxt, MakeAdjustments.Convert('998910'), PostingAccounts,
          NetChange);
        CreateAccScheduleLineExtended(
          XReducedTrialBalanceAccSchedNameTxt, '90', XIncomeBeforeInterestAndTaxTxt, MakeAdjustments.Convert('998995'), TotalAccounts,
          NetChange, true);
    end;

    local procedure SetupAccountSchedulesForO365()
    var
        AccScheduleLine: Record "Acc. Schedule Line";
        BalanceAtDate: Option;
        NetChange: Option;
        PostingAccounts: Option;
        Formula: Option;
    begin
        BalanceAtDate := AccScheduleLine."Row Type"::"Balance at Date";
        NetChange := AccScheduleLine."Row Type"::"Net Change";
        PostingAccounts := AccScheduleLine."Totaling Type"::"Posting Accounts";
        Formula := AccScheduleLine."Totaling Type"::Formula;

        // Account Schedule for Cash Flow Chart
        CreateAccScheduleName(XCashFlowAccSchedNameTxt, StrSubstNo(XAccSchedDescrTxt, ChartManagement.CashFlowChartName),
          XPeriodsColumnLayoutNameTxt);
        CreateAccScheduleLine(XCashFlowAccSchedNameTxt, '10', XTotalReceivablesTxt, CreateGLAccount.AccountReceivableDomestic(), PostingAccounts, BalanceAtDate);
        CreateAccScheduleLine(XCashFlowAccSchedNameTxt, '20', XTotalPayablesTxt, CreateGLAccount.AccountsPayableDomestic(), PostingAccounts, BalanceAtDate);
        CreateAccScheduleLine(XCashFlowAccSchedNameTxt, '30', XTotalLiquidFundsTxt, CreateGLAccount.BusinessaccountOperatingDomestic() + '..' + CreateGLAccount.PettyCash(), PostingAccounts, BalanceAtDate);
        CreateAccScheduleLine(XCashFlowAccSchedNameTxt, '40', XTotalCashFlowTxt, '10..30', Formula, BalanceAtDate);

        // Account Schedule for Income and Expense Chart
        CreateAccScheduleName(
          XIncAndExpAccSchedNameTxt, StrSubstNo(XAccSchedDescrTxt, ChartManagement.IncomeAndExpenseChartName),
          XPeriodsColumnLayoutNameTxt);
        CreateAccScheduleLine(XIncAndExpAccSchedNameTxt, '10', XTotalRevenueCreditTxt, CreateGLAccount.SalesofServiceWork() + '..' + CreateGLAccount.SalesReturns(), PostingAccounts, NetChange);
        CreateAccScheduleLine(XIncAndExpAccSchedNameTxt, '11', XTotalRevenueTxt, '-10', Formula, NetChange);
        CreateAccScheduleLine(XIncAndExpAccSchedNameTxt, '20', XTotalGoodsSoldTxt, CreateGLAccount.CostofMaterials(), PostingAccounts, NetChange);
        CreateAccScheduleLine(XIncAndExpAccSchedNameTxt, '30', XTotalExternalCostsTxt, CreateGLAccount.Rent_Leases() + '..' + CreateGLAccount.AdvertisementDevelopment() + '|' + CreateGLAccount.Bankingfees() + '..' + CreateGLAccount.BadDebtLosses() + '|' + CreateGLAccount.RepairsandMaintenanceforRental() + '..' + CreateGLAccount.OfficeSupplies(),
          PostingAccounts, NetChange);
        CreateAccScheduleLine(XIncAndExpAccSchedNameTxt, '40', XTotalPersonnelCostsTxt, CreateGLAccount.Salaries() + '..' + CreateGLAccount.LifeInsurance(), PostingAccounts, NetChange);
        CreateAccScheduleLine(XIncAndExpAccSchedNameTxt, '50', XTotalFADepricationTxt, CreateGLAccount.DepreciationFixedAssets(), PostingAccounts, NetChange);
        CreateAccScheduleLine(XIncAndExpAccSchedNameTxt, '60', XOtherExpensesTxt, CreateGLAccount.OtherExternalServices(), PostingAccounts, NetChange);
        CreateAccScheduleLine(XIncAndExpAccSchedNameTxt, '70', XTotalExpenditureTxt, '-20..60', Formula, NetChange);
        CreateAccScheduleLine(XIncAndExpAccSchedNameTxt, '80', XEarningsBeforeInterestTxt, '11+70', Formula, NetChange);

        // Account Schedule for Cash Cycle Chart
        CreateAccScheduleName(
          XCashCycleAccSchedNameTxt, StrSubstNo(XAccSchedDescrTxt, ChartManagement.CashCycleChartName), XPeriodsColumnLayoutNameTxt);
        CreateAccScheduleLine(XCashCycleAccSchedNameTxt, '10', XTotalRevenueTxt, CreateGLAccount.SalesofServiceWork() + '..' + CreateGLAccount.SalesReturns(), PostingAccounts, BalanceAtDate);
        CreateAccScheduleLine(XCashCycleAccSchedNameTxt, '20', XTotalReceivablesTxt, CreateGLAccount.AccountReceivableDomestic(), PostingAccounts, BalanceAtDate);
        CreateAccScheduleLine(XCashCycleAccSchedNameTxt, '30', XTotalPayablesTxt, CreateGLAccount.AccountsPayableDomestic(), PostingAccounts, NetChange);
        CreateAccScheduleLine(XCashCycleAccSchedNameTxt, '40', XTotalInventoryTxt, CreateGLAccount.FinishedGoods(), PostingAccounts, NetChange);
        CreateAccScheduleLine(XCashCycleAccSchedNameTxt, '100', XDaysOfSalesOutstandingTxt, '-360*''20''/''10''', Formula, BalanceAtDate);
        CreateAccScheduleLine(XCashCycleAccSchedNameTxt, '110', XDaysOfPaymentOutstandingTxt, '360*''30''/''10''', Formula, BalanceAtDate);
        CreateAccScheduleLine(XCashCycleAccSchedNameTxt, '120', XDaysSalesOfInventoryTxt, '-360*''40''/''10''', Formula, BalanceAtDate);
        CreateAccScheduleLine(XCashCycleAccSchedNameTxt, '200', XCashCycleDaysTxt, '100+110-120', Formula, BalanceAtDate);

        // Account Schedule for Reduced Trial Balance
        CreateAccScheduleName(
          XReducedTrialBalanceAccSchedNameTxt, XReducedTrialBalanceAccSchedDescriptionTxt, XPeriodsColumnLayoutNameTxt);
        CreateAccScheduleLineExtended(XReducedTrialBalanceAccSchedNameTxt, '10', XTotalRevenueTxt, CreateGLAccount.SalesofServiceWork() + '..' + CreateGLAccount.SalesReturns(),
          PostingAccounts, NetChange, true);
        CreateAccScheduleLineExtended(XReducedTrialBalanceAccSchedNameTxt, '20', XTotalCostTxt, CreateGLAccount.CostofMaterials(),
          PostingAccounts, NetChange, false);
        CreateAccScheduleLine(XReducedTrialBalanceAccSchedNameTxt, '30', XGrossMarginTxt, '-10-20', Formula, NetChange);
        CreateAccScheduleLine(XReducedTrialBalanceAccSchedNameTxt, '40', XGrossMarginPctTxt, '-''30''/''10''*100', Formula, NetChange);
        CreateAccScheduleLine(XReducedTrialBalanceAccSchedNameTxt, '50', XOperatingExpensesTxt, CreateGLAccount.Rent_Leases() + '..' + CreateGLAccount.AdvertisementDevelopment() + '|' + CreateGLAccount.Bankingfees() + '..' + CreateGLAccount.OfficeSupplies() + '|' + CreateGLAccount.DepreciationFixedAssets(),
          PostingAccounts, NetChange);
        CreateAccScheduleLine(XReducedTrialBalanceAccSchedNameTxt, '60', XOperatingMarginTxt, '30 - 50', Formula, NetChange);
        CreateAccScheduleLine(XReducedTrialBalanceAccSchedNameTxt, '70', XOperatingMarginPctTxt, '-''60''/''10''*100', Formula, NetChange);
        CreateAccScheduleLine(XReducedTrialBalanceAccSchedNameTxt, '80', XOtherExpensesTxt, CreateGLAccount.OtherExternalServices(), PostingAccounts, NetChange);
        CreateAccScheduleLineExtended(XReducedTrialBalanceAccSchedNameTxt, '90', XIncomeBeforeInterestAndTaxTxt, '60 - 80', Formula,
          NetChange, false);
    end;

    local procedure CreateColumnLayout()
    var
        CreateColumnLayoutName: Codeunit "Create Column Layout Name";
        CreateColumnLayout: Codeunit "Create Column Layout";
    begin
        CreateColumnLayoutName.InsertData(XPeriodsColumnLayoutNameTxt, XPeriodsColumnLayoutNameDescriptionTxt);
        CreateColumnLayout.InsertMiniAppData(XPeriodsColumnLayoutNameTxt, '10', XCurrentPeriodTxt, 10000, '');
        CreateColumnLayout.InsertMiniAppData(XPeriodsColumnLayoutNameTxt, '10', XPeriodMinus1Txt, 20000, InsertPeriodFormula(-1));
        CreateColumnLayout.InsertMiniAppData(XPeriodsColumnLayoutNameTxt, '10', XPeriodMinus2Txt, 30000, InsertPeriodFormula(-2));
    end;

    local procedure InsertFinancialChartDefinitions()
    var
        AccSchedChartSetupLine: Record "Acc. Sched. Chart Setup Line";
        TrialBalanceSetup: Record "Trial Balance Setup";
        Line: Option;
        StepLine: Option;
        Column: Option;
    begin
        Line := AccSchedChartSetupLine."Chart Type"::Line;
        Column := AccSchedChartSetupLine."Chart Type"::Column;
        StepLine := AccSchedChartSetupLine."Chart Type"::StepLine;

        // Cash Flow Chart
        InsertFinancialChartDefinition(
          ChartManagement.CashFlowChartName, XCashFlowChartDescriptionTxt,
          XCashFlowAccSchedNameTxt, XPeriodsColumnLayoutNameTxt, 3, true);
        InsertFinancialChartSetupLine(ChartManagement.CashFlowChartName, XTotalReceivablesTxt, Column, 10000, 10000);
        InsertFinancialChartSetupLine(ChartManagement.CashFlowChartName, XTotalPayablesTxt, Column, 20000, 10000);
        InsertFinancialChartSetupLine(ChartManagement.CashFlowChartName, XTotalLiquidFundsTxt, Column, 30000, 10000);
        InsertFinancialChartSetupLine(ChartManagement.CashFlowChartName, XTotalCashFlowTxt, StepLine, 40000, 10000);

        // Income and Expense Chart
        InsertFinancialChartDefinition(
          ChartManagement.IncomeAndExpenseChartName,
          XIncomeAndExpenseChartDescriptionTxt, XIncAndExpAccSchedNameTxt, XPeriodsColumnLayoutNameTxt, 3, false);
        InsertFinancialChartSetupLine(ChartManagement.IncomeAndExpenseChartName, XTotalRevenueTxt, Column, 20000, 10000);
        InsertFinancialChartSetupLine(ChartManagement.IncomeAndExpenseChartName, XTotalExpenditureTxt, Column, 80000, 10000);
        InsertFinancialChartSetupLine(ChartManagement.IncomeAndExpenseChartName, XEarningsBeforeInterestTxt, Column, 90000, 10000);

        // Cash Cycle Chart
        InsertFinancialChartDefinition(
          ChartManagement.CashCycleChartName,
          XCashCycleChartDescriptionTxt, XCashCycleAccSchedNameTxt, XPeriodsColumnLayoutNameTxt, 12, false);
        InsertFinancialChartSetupLine(ChartManagement.CashCycleChartName, XDaysOfSalesOutstandingTxt, Line, 50000, 10000);
        InsertFinancialChartSetupLine(ChartManagement.CashCycleChartName, XDaysOfPaymentOutstandingTxt, Line, 60000, 10000);
        InsertFinancialChartSetupLine(ChartManagement.CashCycleChartName, XDaysSalesOfInventoryTxt, Line, 70000, 10000);
        InsertFinancialChartSetupLine(ChartManagement.CashCycleChartName, XCashCycleDaysTxt, Line, 80000, 10000);

        // Insert Mini Trial balance
        TrialBalanceSetup.Get();
        TrialBalanceSetup."Account Schedule Name" := XReducedTrialBalanceAccSchedNameTxt;
        TrialBalanceSetup."Column Layout Name" := XPeriodsColumnLayoutNameTxt;
        TrialBalanceSetup.Modify();
    end;

    local procedure InsertFinancialChartDefinition(ChartName: Text[30]; ChartDescription: Text[250]; AccSchedName: Code[10]; ColumnLayoutName: Code[10]; NoOfPeriods: Integer; LookAhead: Boolean)
    var
        AccountSchedulesChartSetup: Record "Account Schedules Chart Setup";
    begin
        AccountSchedulesChartSetup.Init();
        AccountSchedulesChartSetup."User ID" := '';
        AccountSchedulesChartSetup.Name := ChartName;
        AccountSchedulesChartSetup.Description := ChartDescription;
        AccountSchedulesChartSetup."Start Date" := GetCurrentDay;
        AccountSchedulesChartSetup."Account Schedule Name" := AccSchedName;
        AccountSchedulesChartSetup."Column Layout Name" := ColumnLayoutName;
        AccountSchedulesChartSetup."Period Length" := AccountSchedulesChartSetup."Period Length"::Month;
        AccountSchedulesChartSetup."No. of Periods" := NoOfPeriods;
        AccountSchedulesChartSetup."Look Ahead" := LookAhead;
        AccountSchedulesChartSetup.Insert(true);
    end;

    local procedure InsertFinancialChartSetupLine(ChartName: Text[30]; MeasureName: Text[111]; ChartType: Option; AccountScheduleLineNo: Integer; ColumnLayoutLineNo: Integer)
    var
        AccSchedChartSetupLine: Record "Acc. Sched. Chart Setup Line";
        AccountSchedulesChartSetup: Record "Account Schedules Chart Setup";
    begin
        AccountSchedulesChartSetup.Get('', ChartName);

        with AccSchedChartSetupLine do begin
            Init();
            "User ID" := '';
            Name := AccountSchedulesChartSetup.Name;
            "Account Schedule Name" := AccountSchedulesChartSetup."Account Schedule Name";
            "Column Layout Name" := AccountSchedulesChartSetup."Column Layout Name";
            "Account Schedule Line No." := AccountScheduleLineNo;
            "Column Layout Line No." := ColumnLayoutLineNo;
            "Measure Name" := MeasureName;
            "Measure Value" := StrSubstNo('%1 %2', AccountScheduleLineNo, ColumnLayoutLineNo);
            "Chart Type" := ChartType;
            Insert(true);
        end;
    end;

    local procedure CreateAccScheduleName(Name: Code[10]; Description: Text[80]; DefaultColumnLayout: Code[10])
    var
        CreateAccScheduleName: Codeunit "Create Acc. Schedule Name";
    begin
        CreateAccScheduleName.InsertData(Name, Description, DefaultColumnLayout, '');
    end;

    local procedure CreateAccScheduleLine(ScheduleName: Code[10]; RowNo: Code[10]; Description: Text[80]; Totaling: Text[250]; TotalingType: Option; RowType: Option)
    var
        CreateAccScheduleLine: Codeunit "Create Acc. Schedule Line";
    begin
        CreateAccScheduleLine.InsertMiniAppData(ScheduleName, RowNo, Description, Totaling, TotalingType, RowType, false);
    end;

    local procedure CreateAccScheduleLineFormula(ScheduleName: Code[10]; RowNo: Code[10]; Description: Text[80]; Totaling: Text[250]; TotalingType: Option; RowType: Option)
    var
        CreateAccScheduleLine: Codeunit "Create Acc. Schedule Line";
    begin
        CreateAccScheduleLine.InsertMiniAppDataFormula(ScheduleName, RowNo, Description, Totaling, TotalingType, RowType, false, true);
    end;

    local procedure CreateAccScheduleLineExtended(ScheduleName: Code[10]; RowNo: Code[10]; Description: Text[80]; Totaling: Text[250]; TotalingType: Option; RowType: Option; ShowOppositeSign: Boolean)
    var
        CreateAccScheduleLine: Codeunit "Create Acc. Schedule Line";
    begin
        CreateAccScheduleLine.InsertMiniAppData(ScheduleName, RowNo, Description, Totaling, TotalingType, RowType, ShowOppositeSign);
    end;

    local procedure InsertPeriodFormula(Period: Integer): Text[10]
    var
        ColumnLayout: Record "Column Layout";
    begin
        exit(StrSubstNo('%1%2', Period, ColumnLayout.GetPeriodName));
    end;

    procedure GetCashCycleAccSchedName(): Code[10]
    begin
        exit(CopyStr(XCashCycleAccSchedNameTxt, 1, 10));
    end;

    procedure GetIncAndExpAccSchedName(): Code[10]
    begin
        exit(CopyStr(XIncAndExpAccSchedNameTxt, 1, 10));
    end;

    procedure GetReducedTrialBalanceAccSchedName(): Code[10]
    begin
        exit(CopyStr(XReducedTrialBalanceAccSchedNameTxt, 1, 10));
    end;

    local procedure GetCurrentDay(): Date
    var
        MakeAdjustments: Codeunit "Make Adjustments";
    begin
        exit(MakeAdjustments.AdjustDate(19030401D));
    end;
}


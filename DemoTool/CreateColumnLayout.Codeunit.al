codeunit 101334 "Create Column Layout"
{

    trigger OnRun()
    begin
        InsertEvaluationData();
        InsertData(XDEFAULT, '', XNetChangeDebit, 1, 0, 0, '', '', false, 2, 0);
        InsertData(XDEFAULT, '', XNetChangeCredit, 1, 0, 0, '', '', true, 3, 0);
        InsertData(XDEFAULT, '', XBalanceatDateDebit, 2, 0, 0, '', '', false, 2, 0);
        InsertData(XDEFAULT, '', XBalanceatDateCredit, 2, 0, 0, '', '', true, 3, 0);

        InsertData(XACTBUD, 'A', XNetChange, 1, 0, 0, '', '', false, 0, 0);
        InsertData(XACTBUD, 'B', XBudget, 1, 1, 0, '', '', false, 0, 0);
        InsertData(XACTBUD, 'C', XVariance, 0, 0, 0, XAB, '', false, 0, 0);
        InsertData(XACTBUD, 'D', XAB, 0, 0, 0, XAB100, '', false, 0, 0);
        SetHideCurrencySymbol(XACTBUD, 40000);

        InsertData(XBUDGANALYS, XN, XNetChange, 1, 0, 0, '', '', false, 0, 0);
        InsertData(XBUDGANALYS, XB, XBudget, 1, 1, 0, '', '', false, 0, 0);
        VarPercentCalcFormula := '100*(%1/%2-1)';
        VarPercentCalcFormula := StrSubstNo(VarPercentCalcFormula, XN, XB);
        InsertData(XBUDGANALYS, '', XVariancePERCENT, 0, 0, 0, VarPercentCalcFormula, '', false, 0, 0);
        SetHideCurrencySymbol(XBUDGANALYS, 30000);
        // InsertData(XBUDGANALYS,'',XNetChangeLastYear,1,0,0,'','<-1Y>',FALSE,0,0);

        // GB
        InsertData(XBAL_BUDG, XN, XBalance, 2, 0, 0, '', '', false, 0, 0);
        InsertData(XBAL_BUDG, XB, XBudget, 1, 1, 0, '', '', false, 0, 0);
        InsertData(XBAL_BUDG, '', XVariance, 0, 0, 0, 'N-B', '', false, 0, 0);
        InsertData(XBAL_BUDG, '', XVariancePERCENT, 0, 0, 0, '100*(N/B-1)', '', false, 0, 0);

        InsertData(XBAL_LAST, XN, XBalanceThisYear, 2, 0, 0, '', '', false, 0, 0);
        InsertData(XBAL_LAST, XL, XBalanceLastYear, 2, 0, 0, '', '-1Y', false, 0, 0);
        InsertData(XBAL_LAST, '', XVariance, 0, 0, 0, 'N-L', '', false, 0, 0);
        InsertData(XBAL_LAST, '', XVariancePERCENT, 0, 0, 0, '100*(N/L-1)', '', false, 0, 0);

        InsertData(XNET_BUDG, XN, XNetChange, 1, 0, 0, '', '', true, 0, 0);
        InsertData(XNET_BUDG, XB, XBudget, 1, 1, 0, '', '', true, 0, 0);
        InsertData(XNET_BUDG, '', XVariance, 0, 0, 0, 'B-N', '', false, 0, 0);
        InsertData(XNET_BUDG, '', XVariancePERCENT, 0, 0, 0, '100*(N/B-1)', '', false, 0, 0);

        InsertData(XNET_LAST, XN, XNetChangeThisYear, 1, 0, 0, '', '', true, 0, 0);
        InsertData(XNET_LAST, XL, XNetChangeLastYear, 1, 0, 0, '', '-1Y', true, 0, 0);
        InsertData(XNET_LAST, '', XVariance, 0, 0, 0, 'L-N', '', false, 0, 0);
        InsertData(XNET_LAST, '', XVariancePERCENT, 0, 0, 0, '100*(N/L-1)', '', false, 0, 0);
    end;

    var
        "Line No.": Integer;
        "Previous Column Layout Name": Code[10];
        VarPercentCalcFormula: Code[80];
        XDEFAULT: Label 'DEFAULT';
        XNetChangeDebit: Label 'Net Change Debit';
        XNetChangeCredit: Label 'Net Change Credit';
        XBalanceatDateDebit: Label 'Balance at Date Debit';
        XBalanceatDateCredit: Label 'Balance at Date Credit';
        XCASHFLOW: Label 'CASHFLOW', Comment = 'Cashflow is a name of Column Layout.';
        XBALONLY: Label 'BAL ONLY', Comment = 'BAL ONLY is a name of the Column Layout.';
        XAmount: Label 'Amount';
        XAmountUntilDate: Label 'Amount until date';
        XEntireFiscalYear: Label 'Entire Fiscal Year';
        XDEGREE: Label 'DEGREE', Comment = 'Degree is a name of Column Layout.';
        XKeyFigure: Label 'Key Figure';
        XBUDGANALYS: Label 'BUDGANALYS';
        XN: Label 'N';
        XNetChange: Label 'Net Change';
        XB: Label 'B';
        XBudget: Label 'Budget';
        XVariancePERCENT: Label 'Variance%';
        XACTBUD: Label 'Act/Bud';
        XVariance: Label 'Variance';
        XAB: Label 'A-B';
        XAB100: Label 'A / B * 100';
        XNetChangeLastYear: Label 'Net Change Last Year';
        XL: Label 'L';
        XBAL_BUDG: Label 'BAL_BUDG';
        XBAL_LAST: Label 'BAL_LAST';
        XNET_BUDG: Label 'NET_BUDG';
        XNET_LAST: Label 'NET_LAST';
        XBalance: Label 'Balance';
        XNetChangeThisYear: Label 'Net Change This Year';
        XBalanceThisYear: Label 'Balance This Year';
        XBalanceLastYear: Label 'Balance Last Year';

    procedure InsertEvaluationData();
    var
        ColumnLayout: Record "Column Layout";
    begin
        InsertDataLight(XCASHFLOW, 'S10', XAmount, ColumnLayout."Column Type"::"Net Change".AsInteger());
        InsertDataLight(XCASHFLOW, 'S20', XAmountUntilDate, ColumnLayout."Column Type"::"Balance at Date".AsInteger());
        InsertDataLight(XCASHFLOW, 'S30', XEntireFiscalYear, ColumnLayout."Column Type"::"Entire Fiscal Year".AsInteger());
        InsertDataLight(XDEGREE, 'S10', XKeyFigure, ColumnLayout."Column Type"::"Balance at Date".AsInteger());
        InsertDataLight(XBALONLY, '', XBalance, ColumnLayout."Column Type"::"Balance at Date".AsInteger());
    end;

    procedure InsertData("Column Layout Name": Code[10]; "Column No.": Code[10]; "Column Header": Text[30]; "Column Type": Option Formula,"Net Change","Balance at Date","Beginning Balance","Year to Date"," Rest of Fiscal Year","Entire Fiscal Year"; "Ledger Entry Type": Option Entries,"Budget Entries"; "Amount Type": Option "Net Amount","Debit Amount.Credit Amount"; Formula: Code[80]; "Comparison Date Formula": Code[10]; "Show Opposite Sign": Boolean; Show: Option Always,never,"When Positive","When Negative"; "Rounding Factor": Option "None","1","1000","1000000")
    var
        "Column Layout": Record "Column Layout";
    begin
        "Column Layout".Init();
        "Column Layout".Validate("Column Layout Name", "Column Layout Name");
        if "Previous Column Layout Name" <> "Column Layout Name" then begin
            "Line No." := 10000;
            "Previous Column Layout Name" := "Column Layout Name";
        end else
            "Line No." := "Line No." + 10000;
        "Column Layout".Validate("Line No.", "Line No.");
        "Column Layout".Validate("Column No.", "Column No.");
        "Column Layout".Validate("Column Header", "Column Header");
        "Column Layout".Validate("Column Type", "Column Type");
        "Column Layout".Validate("Ledger Entry Type", "Ledger Entry Type");
        "Column Layout".Validate("Amount Type", "Amount Type");
        "Column Layout".Validate(Formula, Formula);
        Evaluate("Column Layout"."Comparison Date Formula", "Comparison Date Formula");
        "Column Layout".Validate("Comparison Date Formula");
        "Column Layout".Validate("Show Opposite Sign", "Show Opposite Sign");
        "Column Layout".Validate(Show, Show);
        "Column Layout".Validate("Rounding Factor", "Rounding Factor");
        "Column Layout".Insert();
    end;

    local procedure InsertDataLight(ColumnLayoutName: Code[10]; ColumnNo: Code[10]; ColumnHeader: Text[30]; ColumnType: Option Formula,"Net Change","Balance at Date","Beginning Balance","Year to Date"," Rest of Fiscal Year","Entire Fiscal Year")
    var
        ColumnLayout: Record "Column Layout";
    begin
        InsertData(
          ColumnLayoutName, ColumnNo, ColumnHeader, ColumnType,
          ColumnLayout."Ledger Entry Type"::Entries.AsInteger(),
          ColumnLayout."Amount Type"::"Net Amount",
          '',
          '',
          false,
          ColumnLayout.Show::Always,
          ColumnLayout."Rounding Factor"::None);
    end;

    procedure InsertMiniAppData(ColumnLayoutName: Code[10]; ColumnNo: Code[10]; ColumnHeader: Code[30]; LineNo: Integer; ComparisonPeriodFormula: Text[10])
    var
        ColumnLayout: Record "Column Layout";
    begin
        ColumnLayout.Init();
        ColumnLayout.Validate("Column Layout Name", ColumnLayoutName);
        ColumnLayout.Validate("Line No.", LineNo);
        ColumnLayout.Validate("Column No.", ColumnNo);
        ColumnLayout.Validate("Column Header", ColumnHeader);
        ColumnLayout.Validate("Comparison Period Formula", ComparisonPeriodFormula);
        ColumnLayout.Insert();

        // Insert "empty" line for applying Acc. Sched. Chart Setup Line throug Rapid Start
        if ColumnLayout.Get('', LineNo) then
            exit;
        ColumnLayout.Init();
        ColumnLayout.Validate("Column Layout Name", '');
        ColumnLayout.Validate("Line No.", LineNo);
        ColumnLayout.Insert();
    end;

    procedure SetHideCurrencySymbol(ColumnLayoutName: Code[10]; LineNo: Integer)
    var
        ColumnLayout: Record "Column Layout";
    begin
        if ColumnLayout.Get(ColumnLayoutName, LineNo) then begin
            ColumnLayout.Validate("Hide Currency Symbol", true);
            ColumnLayout.Modify();
        end;
    end;
}


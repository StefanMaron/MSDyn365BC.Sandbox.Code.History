codeunit 101334 "Create Column Layout"
{

    trigger OnRun()
    begin
        InsertEvaluationData();

        InsertData(XACTBUD, 'A', XNetChange, 1, 0, "Account Schedule Amount Type"::"Net Amount", '', '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
        InsertData(XACTBUD, 'B', XBudget, 1, 1, "Account Schedule Amount Type"::"Net Amount", '', '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
        InsertData(XACTBUD, 'C', XVariance, 0, 0, "Account Schedule Amount Type"::"Net Amount", XAB, '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
        InsertData(XACTBUD, 'D', XAB, 0, 0, "Account Schedule Amount Type"::"Net Amount", XAB100, '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
        SetHideCurrencySymbol(XACTBUD, 40000);

        InsertData(XBUDGANALYS, XN, XNetChange, 1, 0, "Account Schedule Amount Type"::"Net Amount", '', '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
        InsertData(XBUDGANALYS, XB, XBudget, 1, 1, "Account Schedule Amount Type"::"Net Amount", '', '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
        InsertData(XBUDGANALYS, '', Text004, 0, 0, "Account Schedule Amount Type"::"Net Amount", Text000, '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
        InsertData(XBUDGANALYS, '', XNetChangeLastYear, 1, 0, "Account Schedule Amount Type"::"Net Amount", '', '<-1Y>', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
        SetHideCurrencySymbol(XBUDGANALYS, 30000);

        InsertData(Text006, '', Text007, 1, 0, "Account Schedule Amount Type"::"Net Amount", '', '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
        InsertData(Text006, '', Text008, 4, 0, "Account Schedule Amount Type"::"Net Amount", '', '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
        InsertData(Text009, Text010, Text007, 0, 1, "Account Schedule Amount Type"::"Net Amount", '', '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
        InsertData(Text009, '', '', 0, 0, "Account Schedule Amount Type"::"Net Amount", Text011, '', true, "Column Layout Show"::Always, "Analysis Rounding Factor"::"1");
        InsertData(Text009, Text012, Text008, 4, 0, "Account Schedule Amount Type"::"Net Amount", '', '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
        InsertData(Text009, '', '', 0, 0, "Account Schedule Amount Type"::"Net Amount", Text013, '', true, "Column Layout Show"::Always, "Analysis Rounding Factor"::"1");
        InsertData(Text014, Text015, Text016, 4, 0, "Account Schedule Amount Type"::"Net Amount", '', '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::"1");
        InsertData(Text014, '', '', 0, 0, "Account Schedule Amount Type"::"Net Amount", Text017, '', true, "Column Layout Show"::Always, "Analysis Rounding Factor"::"1");
        InsertData(Text014, Text018, Text019, 4, 0, "Account Schedule Amount Type"::"Net Amount", '', '<-1Y>', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::"1");
        InsertData(Text014, '', '', 0, 0, "Account Schedule Amount Type"::"Net Amount", Text020, '', true, "Column Layout Show"::Always, "Analysis Rounding Factor"::"1");
        InsertData(Text014, Text021, Text022, 0, 0, "Account Schedule Amount Type"::"Net Amount", Text023, '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::"1");
    end;

    var
        Text000: Label '100*(N/B-1)';
        Text002: Label 'BAL ONLY';
        Text003: Label 'Balance';
        Text004: Label 'Deviation from Budget %';
        Text006: Label 'PTD + YTD';
        Text007: Label 'Current Period';
        Text008: Label 'Year to Date';
        Text009: Label 'PTD+YTD+%';
        Text010: Label 'PTD';
        Text011: Label 'PTD%';
        Text012: Label 'YTD';
        Text013: Label 'YTD%';
        Text014: Label 'YTDCOMPARE';
        Text015: Label 'CUR';
        Text016: Label 'Current Year to Date';
        Text017: Label 'CUR%';
        Text018: Label 'PRIOR';
        Text019: Label 'Prior Year to Date';
        Text020: Label 'PRIOR%';
        Text021: Label 'DIFF';
        Text022: Label 'Difference';
        Text023: Label 'CUR-PRIOR';
        "Line No.": Integer;
        "Previous Column Layout Name": Code[10];
        XDEFAULT: Label 'DEFAULT';
        XNetChangeDebit: Label 'Net Change Debit';
        XNetChangeCredit: Label 'Net Change Credit';
        XBalanceatDateDebit: Label 'Balance at Date Debit';
        XBalanceatDateCredit: Label 'Balance at Date Credit';
        XCASHFLOW: Label 'CASHFLOW', Comment = 'Cashflow is a name of Column Layout.';
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
        XACTBUD: Label 'Act/Bud';
        XVariance: Label 'Variance';
        XAB: Label 'A-B';
        XAB100: Label 'A / B * 100';
        XNetChangeLastYear: Label 'Net Change Last Year';

    procedure InsertEvaluationData();
    var
        ColumnLayout: Record "Column Layout";
    begin
        InsertDataLight(XCASHFLOW, 'S10', XAmount, ColumnLayout."Column Type"::"Net Change".AsInteger());
        InsertDataLight(XCASHFLOW, 'S20', XAmountUntilDate, ColumnLayout."Column Type"::"Balance at Date".AsInteger());
        InsertDataLight(XCASHFLOW, 'S30', XEntireFiscalYear, ColumnLayout."Column Type"::"Entire Fiscal Year".AsInteger());
        InsertDataLight(XDEGREE, 'S10', XKeyFigure, ColumnLayout."Column Type"::"Balance at Date".AsInteger());
        InsertData(XDEFAULT, '', XNetChangeDebit, 1, 0, "Account Schedule Amount Type"::"Net Amount", '', '', false, "Column Layout Show"::"When Positive", "Analysis Rounding Factor"::None);
        InsertData(XDEFAULT, '', XNetChangeCredit, 1, 0, "Account Schedule Amount Type"::"Net Amount", '', '', true, "Column Layout Show"::"When Negative", "Analysis Rounding Factor"::None);
        InsertData(XDEFAULT, '', XBalanceatDateDebit, 2, 0, "Account Schedule Amount Type"::"Net Amount", '', '', false, "Column Layout Show"::"When Positive", "Analysis Rounding Factor"::None);
        InsertData(XDEFAULT, '', XBalanceatDateCredit, 2, 0, "Account Schedule Amount Type"::"Net Amount", '', '', true, "Column Layout Show"::"When Negative", "Analysis Rounding Factor"::None);
        InsertData(Text002, '', Text003, 2, 0, "Account Schedule Amount Type"::"Net Amount", '', '', false, "Column Layout Show"::Always, "Analysis Rounding Factor"::None);
    end;

    procedure InsertData(ColumnLayoutName: Code[10]; "Column No.": Code[10]; "Column Header": Text[30]; "Column Type": Option Formula,"Net Change","Balance at Date","Beginning Balance","Year to Date"," Rest of Fiscal Year","Entire Fiscal Year"; "Ledger Entry Type": Option Entries,"Budget Entries"; "Amount Type": Enum "Account Schedule Amount Type"; Formula: Code[80]; "Comparison Date Formula": Code[10]; "Show Opposite Sign": Boolean; Show: Enum "Column Layout Show"; "Rounding Factor": Enum "Analysis Rounding Factor")
    begin
        InsertData(ColumnLayoutName, "Column No.", "Column Header", "Column Type", "Ledger Entry Type", "Amount Type", Formula, "Comparison Date Formula", "Show Opposite Sign", Show, "Rounding Factor", '', 0);
    end;

    procedure InsertData(ColumnLayoutName: Code[10]; "Column No.": Code[10]; "Column Header": Text[30]; "Column Type": Option Formula,"Net Change","Balance at Date","Beginning Balance","Year to Date"," Rest of Fiscal Year","Entire Fiscal Year"; "Ledger Entry Type": Option Entries,"Budget Entries"; "Amount Type": Enum "Account Schedule Amount Type"; Formula: Code[80]; "Comparison Date Formula": Code[10]; "Show Opposite Sign": Boolean; Show: Enum "Column Layout Show"; "Rounding Factor": Enum "Analysis Rounding Factor"; ComparisonPeriodFormula: Code[20]; ComparisonPeriodFormulaLCID: Integer)
    var
        "Column Layout": Record "Column Layout";
    begin
        "Column Layout".Init();
        "Column Layout".Validate("Column Layout Name", ColumnLayoutName);
        if "Previous Column Layout Name" <> ColumnLayoutName then begin
            "Line No." := 10000;
            "Previous Column Layout Name" := ColumnLayoutName;
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
        "Column Layout".Validate("Comparison Period Formula LCID", ComparisonPeriodFormulaLCID);
        "Column Layout"."Comparison Period Formula" := ComparisonPeriodFormula;
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

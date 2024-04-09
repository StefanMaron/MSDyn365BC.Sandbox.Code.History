codeunit 101333 "Create Column Layout Name"
{

    trigger OnRun()
    begin
        InsertEvaluationData();
        InsertData(XBUDGANALYS, XBudgetAnalysis);
        InsertData(XACTBUD, XActBudComparision);
        InsertData(Text002, Text003);
        InsertData(Text004, Text005);
        InsertData(Text006, Text007);
    end;

    var
        XCASHFLOW: Label 'CASHFLOW', Comment = 'Cashflow is a name of the Column Layout.';
        XComparisonMonthYear: Label 'Comparison month - year';
        XDEGREE: Label 'DEGREE';
        XKeyCashFlowRatioTxt: Label 'Key Cash Flow Ratio';
        XBUDGANALYS: Label 'BUDGANALYS';
        XBudgetAnalysis: Label 'Budget Analysis';
        XDEFAULT: Label 'DEFAULT', Comment = 'Default is a name of Column Layout.';
        XStandardColumnLayout: Label 'Standard Column Layout';
        XACTBUD: Label 'Act/Bud';
        XActBudComparision: Label 'Actual / Budget Comparision';
        Text000: Label 'BAL ONLY';
        Text001: Label 'Balance Only';
        Text002: Label 'PTD + YTD';
        Text003: Label 'Period and Year to Date';
        Text004: Label 'PTD+YTD+%';
        Text005: Label 'Period and Year to Date with Percent of Total Revenue';
        Text006: Label 'YTDCOMPARE';
        Text007: Label 'This Year to Date vs. Prior Year to Date';

    procedure InsertEvaluationData();
    begin
        InsertData(XCASHFLOW, XComparisonMonthYear);
        InsertData(XDEGREE, XKeyCashFlowRatioTxt);
        InsertData(XDEFAULT, XStandardColumnLayout);
        InsertData(Text000, Text001);
    end;

    procedure InsertData(Name: Code[10]; Description: Text[80])
    var
        "Column Layout Name": Record "Column Layout Name";
    begin
        "Column Layout Name".Init();
        "Column Layout Name".Validate(Name, Name);
        "Column Layout Name".Validate(Description, Description);
        "Column Layout Name".Insert();
    end;
}

codeunit 101333 "Create Column Layout Name"
{

    trigger OnRun()
    begin
        InsertEvaluationData();
        InsertData(XBUDGANALYS, XBudgetAnalysis);
        InsertData(XDEFAULT, XStandardColumnLayout);
        InsertData(XACTBUD, XActBudComparision);
    end;

    var
        XCASHFLOW: Label 'CASHFLOW', Comment = 'Cashflow is a name of the Column Layout.';
        XBALONLY: Label 'BAL ONLY', Comment = 'BAL ONLY is a name of the Column Layout.';
        XBalanceOnly: Label 'Balance Only';
        XComparisonMonthYear: Label 'Comparison month - year';
        XDEGREE: Label 'DEGREE';
        XKeyCashFlowRatioTxt: Label 'Key Cash Flow Ratio';
        XBUDGANALYS: Label 'BUDGANALYS';
        XBudgetAnalysis: Label 'Budget Analysis';
        XDEFAULT: Label 'DEFAULT', Comment = 'Default is a name of Column Layout.';
        XStandardColumnLayout: Label 'Standard Column Layout';
        XACTBUD: Label 'Act/Bud';
        XActBudComparision: Label 'Actual / Budget Comparision';
        XBALANCESHT: Label 'BALANCESHT', Comment = 'Balance Sheet';
        XBalanceSheet: Label 'Balance Sheet';
        XINCOMESTMT: Label 'INCOMESTMT', Comment = 'Income Statement';
        XIncomeStatement: Label 'Income Statement';

    procedure InsertEvaluationData();
    begin
        InsertData(XCASHFLOW, XComparisonMonthYear);
        InsertData(XDEGREE, XKeyCashFlowRatioTxt);
        InsertData(XBALONLY, XBalanceOnly);
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

    procedure InsertMiniAppData()
    begin
        InsertData(XBALANCESHT, XBalanceSheet);
        InsertData(XINCOMESTMT, XIncomeStatement);
    end;

    procedure GetColumnLayoutName(ColumnLayoutName: Text): Code[10]
    begin
        case UpperCase(ColumnLayoutName) of
            'XCASHFLOW':
                exit(XCASHFLOW);
            'XBALONLY':
                exit(XBALONLY);
            'XDEGREE':
                exit(XDEGREE);
            'XBUDGANALYS':
                exit(XBUDGANALYS);
            'XDEFAULT':
                exit(XDEFAULT);
            'XACTBUD':
                exit(XACTBUD);
            'XBALANCESHT':
                exit(XBALANCESHT);
            'XINCOMESTMT':
                exit(XINCOMESTMT);
        end;
    end;
}

codeunit 101333 "Create Column Layout Name"
{

    trigger OnRun()
    begin
        InsertEvaluationData();
        InsertData(XBUDGANALYS, XBudgetAnalysis);
        InsertData(XACTBUD, XActBudComparision);
        InsertData(XBALANCE, XBalanceColumnLayout);
        InsertData(XPYG, XProfitLossColumnLayout);
        InsertData(XCCPERS, XContstaffcosts);
        InsertData(XCCPROF, XBDinfPostingsummarycostsforCCCO);
        InsertData(XCCTRANS, XConttransfercosts);
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
        XBALANCE: Label 'BALANCE';
        XPYG: Label 'PYG';
        XBalanceColumnLayout: Label 'Balance Column Layout';
        XProfitLossColumnLayout: Label 'Profit & Loss Column Layout';
        XCCPERS: Label 'CC-PERS';
        XCCPROF: Label 'CC-PROF';
        XCCTRANS: Label 'CC-TRANS';
        XContstaffcosts: Label 'Cont. staff costs';
        XBDinfPostingsummarycostsforCCCO: Label 'BD inf.Posting summary costs for CC/CO';
        XConttransfercosts: Label 'Cont. transfer costs';

    procedure InsertEvaluationData();
    begin
        InsertData(XCASHFLOW, XComparisonMonthYear);
        InsertData(XDEGREE, XKeyCashFlowRatioTxt);
        InsertData(XDEFAULT, XStandardColumnLayout);
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


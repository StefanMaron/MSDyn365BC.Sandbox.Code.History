codeunit 101258 "Create Transaction Type"
{

    trigger OnRun()
    begin
        InsertData('1', XOrdinarypurchasesale);
        InsertData('2', XReturnofprevrecdshippedgoods);
        InsertData('3', XGoodsusedinEUaidprograms);
        InsertData('4', XProcessingundercontract);
        InsertData('5', XAftercontractwork);
        InsertData('7', XJointdefenseprojects);
        InsertData('8', XConstructionmatcovbycontract);
        InsertData('9', XOther);
    end;

    var
        "Transaction Type": Record "Transaction Type";
        XOrdinarypurchasesale: Label 'Ordinary purchase/sale';
        XPurchsaleafterinspectiontrial: Label 'Purchase/sale after inspection/trial';
        XBarterExchanges: Label 'Barter/Exchanges';
        XFinancialleasing: Label 'Financial leasing';
        XReturnofprevrecdshippedgoods: Label 'Return of previously recd./shipped goods';
        XExchangeofreturnedgoods: Label 'Exchange of returned goods';
        XExchangeofnonreturnedgoods: Label 'Exchange of non-returned goods';
        XGoodsusedinEUaidprograms: Label 'Goods used in EU aid programs';
        XOtherpublicsupport: Label 'Other public support';
        XOtherprivatesupport: Label 'Other (private) support';
        XProcessingundercontract: Label 'Processing under contract';
        XForrepairmaintenancewithfee: Label 'For repair/maintenance with fee';
        XForrepmaintwithoutcharge: Label 'For repair/maintenance without charge';
        XAftercontractwork: Label 'After contract work';
        XAfterrepairmaintenancewithfee: Label 'After repair/maintenance with fee';
        XAfterrepmaintwithoutcharge: Label 'After repair/maintenance without charge';
        XOperationalleasing: Label 'Operational leasing';
        XJointdefenseprojects: Label 'Joint defense projects';
        XConstructionmatcovbycontract: Label 'Construction materials covered by contract';
        XEUgoodssameownsenttoprivstor: Label 'EU goods (same owner) sent to private storage';
        XEUgoodsrecdforprivatestorage: Label 'EU goods received for private storage';
        XOther: Label 'Other';

    procedure InsertData("Code": Code[10]; Description: Text[80])
    begin
        "Transaction Type".Init();
        "Transaction Type".Validate(Code, Code);
        "Transaction Type".Validate(Description, Description);
        "Transaction Type".Insert();
    end;
}


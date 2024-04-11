codeunit 101258 "Create Transaction Type"
{

    trigger OnRun()
    begin
        // SE
        //InsertData('11',XOrdinarypurchasesale);
        //InsertData('12',XPurchsaleafterinspectiontrial);
        //InsertData('13',XBarterExchanges);
        //InsertData('15',XFinancialleasing);
        //InsertData('21',XReturnofprevrecdshippedgoods);
        //InsertData('22',XExchangeofreturnedgoods);
        //InsertData('23',XExchangeofnonreturnedgoods);
        //InsertData('31',XGoodsusedinEUaidprograms);
        //InsertData('32',XOtherpublicsupport);
        //InsertData('33',XOtherprivatesupport);
        //InsertData('41',XProcessingundercontract);
        //InsertData('42',XForrepairmaintenancewithfee);
        //InsertData('43',XForrepmaintwithoutcharge);
        //InsertData('51',XAftercontractwork);
        //InsertData('52',XAfterrepairmaintenancewithfee);
        //InsertData('53',XAfterrepmaintwithoutcharge);
        //InsertData('61',XOperationalleasing);
        //InsertData('70',XJointdefenseprojects);
        //InsertData('80',XConstructionmatcovbycontract);
        //InsertData('91',XEUgoodssameownsenttoprivstor);
        //InsertData('92',XEUgoodsrecdforprivatestorage);
        //InsertData('99',XOther);
        InsertData('1', XPurchasesaleofcommodities);
        InsertData('2', XReturnreplacementofommodities);
        InsertData('3', XDeleveriesfordevelopment);
        InsertData('4', XDeliveriesforprocessing);
        InsertData('5', XDeliveriesafterprocessing);
        InsertData('6', XNationalcode);
        InsertData('7', XDeliveriesforjointdefenceproj);
        InsertData('8', XSupplyofbuildingmaterials);
        InsertData('9', XOthertransactions);
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
        XPurchasesaleofcommodities: Label 'Purchase/sale of Commodities';
        XReturnreplacementofommodities: Label 'Return/replacement of Commodities';
        XDeleveriesfordevelopment: Label 'Deliveries for development assistance programmes/aid deliveries';
        XDeliveriesforprocessing: Label 'Deliveries for processing under contract';
        XDeliveriesafterprocessing: Label 'Deliveries after processing under contract';
        XNationalcode: Label 'National code, not used in Sweden';
        XDeliveriesforjointdefenceproj: Label 'Deliveries for joint defence projects/government projects';
        XSupplyofbuildingmaterials: Label 'Supply of building materials/equipment for works part of constr/eng contract';
        XOthertransactions: Label 'Gifts/Moving of own inventory, etc.';

    procedure InsertData("Code": Code[10]; Description: Text[80])
    begin
        "Transaction Type".Init();
        "Transaction Type".Validate(Code, Code);
        "Transaction Type".Validate(Description, Description);
        "Transaction Type".Insert();
    end;
}


codeunit 101256 "Create VAT Statement Line"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        if DemoDataSetup."Company Type" = DemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        InsertData(
          '1010', StrSubstNo(XSalesVATPERCENToutgoing, DemoDataSetup.GoodsVATText()), 1, '', 2, DemoDataSetup.DomesticCode(), DemoDataSetup.GoodsVATCode(), '', 1, 0, false, 1, false);
        InsertData(
          '1020', StrSubstNo(XSalesVATPERCENToutgoing, DemoDataSetup.ServicesVATText()), 1, '', 2, DemoDataSetup.DomesticCode(), DemoDataSetup.ServicesVATCode(), '', 1, 0, false, 1, false);
        InsertData(
          '1050', StrSubstNo(XVATPERCENTonEUPurchasesetc, DemoDataSetup.GoodsVATText()), 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.GoodsVATCode(), '', 1, 1, false, 1, false);
        InsertData(
          '1060', StrSubstNo(XVATPERCENTonEUPurchasesetc, DemoDataSetup.ServicesVATText()), 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.ServicesVATCode(), '', 1, 1, false, 1, false);
        if DemoDataSetup."Reduced VAT Rate" > 0 then begin
            InsertData(
              '1030', StrSubstNo(XSalesVATPERCENToutgoing, DemoDataSetup.ReducedVATText()), 1, '', 2, DemoDataSetup.DomesticCode(), DemoDataSetup.ReducedVATCode(), '', 1, 0, false, 1, false);
            InsertData(
              '1070', StrSubstNo(XVATPERCENTonEUPurchasesetc, DemoDataSetup.ReducedVATText()), 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.ReducedVATCode(), '', 1, 1, false, 1, false);
        end;
        InsertData('', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData('1099', XTotal, 2, '', 0, '', '', '1010..1090', 0, 0, true, 1, false);
        InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData(
          '1110', StrSubstNo(XPurchaseVATPERCENTDomestic, DemoDataSetup.GoodsVATText()), 1, '', 1, DemoDataSetup.DomesticCode(), DemoDataSetup.GoodsVATCode(), '', 1, 0, false, 0, false);
        InsertData(
          '1120', StrSubstNo(XPurchaseVATPERCENTDomestic, DemoDataSetup.ServicesVATText()), 1, '', 1, DemoDataSetup.DomesticCode(), DemoDataSetup.ServicesVATCode(), '', 1, 0, false, 0, false);
        InsertData(
          '1150', StrSubstNo(XPurchaseVATPERCENTEU, DemoDataSetup.GoodsVATText()), 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.GoodsVATCode(), '', 1, 0, false, 0, false);
        InsertData(
          '1160', StrSubstNo(XPurchaseVATPERCENTEU, DemoDataSetup.ServicesVATText()), 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.ServicesVATCode(), '', 1, 0, false, 0, false);
        if DemoDataSetup."Reduced VAT Rate" > 0 then begin
            InsertData(
              '1130', StrSubstNo(XPurchaseVATPERCENTDomestic, DemoDataSetup.ReducedVATText()), 1, '', 1, DemoDataSetup.DomesticCode(), DemoDataSetup.ReducedVATCode(), '', 1, 0, false, 0, false);
            InsertData(
              '1170', StrSubstNo(XPurchaseVATPERCENTEU, DemoDataSetup.ReducedVATText()), 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.ReducedVATCode(), '', 1, 0, false, 0, false);
        end;
        InsertData('1179', XPurchaseVATingoing, 2, '', 0, '', '', '1110..1170', 0, 0, true, 1, false);
        InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData('1180', XFuelTax, 0, '24210', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1181', XElectricityTax, 0, '24220', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1182', XNaturalGasTax, 0, '24240', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1183', XCoalTax, 0, '', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1184', XCO2Tax, 0, '24230', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1185', XWaterTax, 0, '24250', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1189', XTotalTaxes, 2, '', 0, '', '', '1180..1188', 0, 0, true, 1, false);
        InsertData('', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData('1199', XTotalDeductions, 2, '', 0, '', '', '1159|1189', 0, 0, true, 1, false);
        InsertData('', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData('', XVATPayable, 2, '', 0, '', '', '1099|1199', 0, 0, true, 1, false);
        InsertData('', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData(
          '1210', StrSubstNo(XValueofEUPurchasesPERCENT, DemoDataSetup.GoodsVATText()), 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.GoodsVATCode(), '', 2, 0, false, 0, false);
        InsertData(
          '1220', StrSubstNo(XValueofEUPurchasesPERCENT, DemoDataSetup.ServicesVATText()), 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.ServicesVATCode(), '', 2, 0, false, 0, false);
        if DemoDataSetup."Reduced VAT Rate" > 0 then
            InsertData(
              '1230', StrSubstNo(XValueofEUPurchasesPERCENT, DemoDataSetup.ReducedVATText()), 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.ReducedVATCode(), '', 2, 0, false, 0, false);
        InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData(
          '1240', StrSubstNo(XValueofEUSalesPERCENT, DemoDataSetup.GoodsVATText()), 1, '', 2, DemoDataSetup.EUCode(), DemoDataSetup.GoodsVATCode(), '', 2, 0, false, 1, false);
        InsertData(
          '1250', StrSubstNo(XValueofEUSalesPERCENT, DemoDataSetup.ServicesVATText()), 1, '', 2, DemoDataSetup.EUCode(), DemoDataSetup.ServicesVATCode(), '', 2, 0, false, 1, false);
        if DemoDataSetup."Reduced VAT Rate" > 0 then
            InsertData('1260', StrSubstNo(XValueofEUSalesPERCENT, DemoDataSetup.ReducedVATText()), 1, '', 2, DemoDataSetup.EUCode(), DemoDataSetup.ReducedVATCode(), '', 2, 0, false, 1, false);
        InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData('1310', XNonVATliablesalesOverseas, 1, '', 2, DemoDataSetup.ExportCode(), DemoDataSetup.GoodsVATCode(), '', 2, 0, false, 0, false);
        InsertData('1320', XNonVATliablesalesOverseas, 1, '', 2, DemoDataSetup.ExportCode(), DemoDataSetup.ServicesVATCode(), '', 2, 0, false, 0, false);
        if DemoDataSetup."Reduced VAT Rate" > 0 then
            InsertData('1330', XNonVATliablesalesOverseas, 1, '', 2, DemoDataSetup.ExportCode(), DemoDataSetup.ReducedVATCode(), '', 2, 0, false, 0, false);
        InsertData('', XNonVATliablesalesOverseas, 2, '', 0, '', '', '1310..1330', 0, 0, true, 1, false);
        InsertData('1340', XNonVATliablesalesDomestic, 1, '', 2, DemoDataSetup.DomesticCode(), DemoDataSetup.NoVATCode(), '', 2, 0, false, 0, false);
        InsertData('', XNonVATliablesalesDomestic, 2, '', 0, '', '', '1340..1348', 0, 0, true, 1, false);
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        NextLineNo: Integer;
        XSalesVATPERCENToutgoing: Label 'Sales VAT %1 (outgoing)';
        XVATPERCENTonEUPurchasesetc: Label 'VAT %1 % on EU Purchases etc.';
        XPurchaseVATPERCENTDomestic: Label 'Purchase VAT %1 Domestic';
        XPurchaseVATPERCENTEU: Label 'Purchase VAT %1 EU';
        XValueofEUPurchasesPERCENT: Label 'Value of EU Purchases %1';
        XValueofEUSalesPERCENT: Label 'Value of EU Sales %1';
        XTotal: Label 'Total';
        XPurchaseVATingoing: Label 'Purchase VAT (ingoing)';
        XFuelTax: Label 'Fuel Tax';
        XElectricityTax: Label 'Electricity Tax';
        XNaturalGasTax: Label 'Natural Gas Tax';
        XCoalTax: Label 'Coal Tax';
        XCO2Tax: Label 'CO2 Tax';
        XWaterTax: Label 'Water Tax';
        XTotalTaxes: Label 'Total Taxes';
        XTotalDeductions: Label 'Total Deductions';
        XVATPayable: Label 'VAT Payable';
        XNonVATliablesalesOverseas: Label 'Non-VAT liable sales, Overseas';
        XNonVATliablesalesDomestic: Label 'Non-VAT liable sales, Domestic';
        XVAT: Label 'VAT';
        XDEFAULT: Label 'DEFAULT';
        XVAT25PERCENTonForeignPurchasesTxt: Label 'VAT 25% on foreign purchases', Locked = true;
        XVAT25PERCENTonForeignPurchases2Txt: Label 'VAT 25% on foreign purchases', Locked = true;
        XVAT25PERCENTonForeignPurchasesTotalingTxt: Label 'VAT 25% on goods purchased abroad', Locked = true;
        XServicePurchaseVAT25EUTxt: Label 'VAT 25% on EU service purchases', Locked = true;
        XServicePurchaseVAT25EU2Txt: Label 'VAT 25% on EU service purchases', Locked = true;
        XServicePurchaseVAT25ForeignTxt: Label 'VAT 25% on foreign service purchases', Locked = true;
        XServicePurchaseVAT25Foreign2Txt: Label 'VAT 25% on service purchases, foreign', Locked = true;
        XServicePurchaseVAT25ForeignTotalingTxt: Label 'VAT 25% on foreign service purchases', Locked = true;
        XValueServicePurchaseVAT25EUTxt: Label 'Value of EU service purchases 25 %', Locked = true;
        XValueOfEUSalesNoVATTxt: Label 'Value of non-VAT liable EU sales', Locked = true;
        XValueOfEUSalesNoVATOtherTxt: Label 'Value of non-VAT liable EU sales, other', Locked = true;
        XNonVATliablesalesExportTxt: Label 'Non-VAT liable sales, Export', Locked = true;
        XNonVATliablesalesDenmarkTxt: Label 'Non-VAT liable sales, Denmark', Locked = true;

    procedure InsertData(RowNo: Code[10]; Description: Text[50]; Type: Option; AccountTotaling: Text[30]; GenPostingType: Option; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; RowTotaling: Text[30]; AmountType: Option; CalculateWith: Option; Print: Boolean; PrintWith: Option; NewPage: Boolean)
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        VATStatementLine.Init();
        VATStatementLine.Validate("Statement Template Name", XVAT);
        VATStatementLine.Validate("Statement Name", XDEFAULT);
        NextLineNo := NextLineNo + 10000;
        VATStatementLine.Validate("Line No.", NextLineNo);
        VATStatementLine.Validate("Row No.", RowNo);
        VATStatementLine.Validate(Description, Description);
        VATStatementLine.Validate(Type, Type);
        VATStatementLine.Validate("Account Totaling", AccountTotaling);
        VATStatementLine.Validate("Gen. Posting Type", GenPostingType);
        VATStatementLine.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        VATStatementLine.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        VATStatementLine.Validate("Row Totaling", RowTotaling);
        VATStatementLine.Validate("Amount Type", AmountType);
        VATStatementLine.Validate("Calculate with", CalculateWith);
        VATStatementLine.Validate(Print, Print);
        VATStatementLine.Validate("Print with", PrintWith);
        VATStatementLine.Validate("New Page", NewPage);
        VATStatementLine.Insert();
    end;

    procedure InsertMiniAppData()
    begin
        DemoDataSetup.Get();
        if DemoDataSetup."Company Type" = DemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        InsertData('1010', StrSubstNo(XSalesVATPERCENToutgoing, DemoDataSetup.GoodsVATText()), 1, '', 2, DemoDataSetup.DomesticCode(), DemoDataSetup.GoodsVATCode(), '', 1, 0, false, 1, false);
        InsertData('1019', StrSubstNo(XSalesVATPERCENToutgoing, DemoDataSetup.GoodsVATText()), 2, '', 0, '', '', '1010..1018', 0, 0, true, 1, false);
        InsertData('1030', StrSubstNo(XVATPERCENTonEUPurchasesetc, DemoDataSetup.GoodsVATText()), 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.GoodsVATCode(), '', 1, 1, false, 1, false);
        InsertData('1031', XVAT25PERCENTonForeignPurchasesTxt, 1, '', 1, DemoDataSetup.ExportCode(), DemoDataSetup.GoodsVATCode(), '', 1, 1, false, 0, false);
        InsertData('1039', XVAT25PERCENTonForeignPurchasesTotalingTxt, 2, '', 0, '', '', '1030..1038', 0, 0, true, 1, false);
        InsertData('1040', XServicePurchaseVAT25EUTxt, 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.ServicesVATCode(), '', 1, 1, false, 0, false);
        InsertData('1041', XServicePurchaseVAT25ForeignTxt, 1, '', 1, DemoDataSetup.ExportCode(), DemoDataSetup.ServicesVATCode(), '', 1, 1, false, 0, false);
        InsertData('1049', XServicePurchaseVAT25ForeignTotalingTxt, 2, '', 0, '', '', '1040..1048', 0, 0, true, 1, false);
        InsertData('1050', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData('1070', XTotal, 2, '', 0, '', '', '1019|1039|1049', 0, 0, true, 1, false);
        InsertData('1099', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1110', StrSubstNo(XPurchaseVATPERCENTDomestic, DemoDataSetup.GoodsVATText()), 1, '', 1, DemoDataSetup.DomesticCode(), DemoDataSetup.GoodsVATCode(), '', 1, 0, false, 0, false);
        InsertData('1130', StrSubstNo(XPurchaseVATPERCENTEU, DemoDataSetup.GoodsVATText()), 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.GoodsVATCode(), '', 1, 0, false, 0, false);
        InsertData('1131', XVAT25PERCENTonForeignPurchases2Txt, 1, '', 1, DemoDataSetup.ExportCode(), DemoDataSetup.GoodsVATCode(), '', 1, 0, false, 0, false);
        InsertData('1140', XServicePurchaseVAT25EU2Txt, 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.ServicesVATCode(), '', 1, 0, false, 0, false);
        InsertData('1141', XServicePurchaseVAT25Foreign2Txt, 1, '', 1, DemoDataSetup.ExportCode(), DemoDataSetup.ServicesVATCode(), '', 1, 0, false, 0, false);
        InsertData('1159', XPurchaseVATingoing, 2, '', 0, '', '', '1110..1158', 0, 0, true, 1, false);
        InsertData('1160', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData('1180', XFuelTax, 0, '24210', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1181', XElectricityTax, 0, '24220', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1182', XNaturalGasTax, 0, '24240', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1183', XCoalTax, 0, '', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1184', XCO2Tax, 0, '24230', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1185', XWaterTax, 0, '24250', 0, '', '', '', 0, 0, true, 1, false);
        InsertData('1189', XTotalTaxes, 2, '', 0, '', '', '1180..1188', 0, 0, true, 1, false);
        InsertData('1190', XTotalDeductions, 2, '', 0, '', '', '1159|1189', 0, 0, true, 1, false);
        InsertData('1194', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData('1195', XVATPayable, 2, '', 0, '', '', '1070|1190', 0, 0, true, 1, false);
        InsertData('1196', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData('1210', StrSubstNo(XValueofEUPurchasesPERCENT, DemoDataSetup.GoodsVATText()), 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.GoodsVATCode(), '', 2, 0, false, 0, false);
        InsertData('1219', StrSubstNo(XValueofEUPurchasesPERCENT, DemoDataSetup.GoodsVATText()), 2, '', 0, '', '', '1210..1218', 0, 0, true, 0, false);
        InsertData('1220', XValueServicePurchaseVAT25EUTxt, 1, '', 1, DemoDataSetup.EUCode(), DemoDataSetup.ServicesVATCode(), '', 2, 0, false, 0, false);
        InsertData('1229', XValueServicePurchaseVAT25EUTxt, 2, '', 0, '', '', '1220..1228', 0, 0, true, 0, false);
        InsertData('1230', XValueOfEUSalesNoVATTxt, 1, '', 2, DemoDataSetup.EUCode(), DemoDataSetup.NoVATCode(), '', 2, 0, false, 0, false);
        InsertData('1239', XValueOfEUSalesNoVATTxt, 2, '', 0, '', '', '1230..1238', 0, 0, true, 0, false);
        InsertData('1240', XValueOfEUSalesNoVATOtherTxt, 1, '', 0, '', '', '', 0, 0, false, 0, false);
        InsertData('1249', XValueOfEUSalesNoVATOtherTxt, 2, '', 0, '', '', '', 0, 0, true, 0, false);
        InsertData('1310', XNonVATliablesalesExportTxt, 1, '', 2, DemoDataSetup.ExportCode(), DemoDataSetup.NoVATCode(), '', 2, 0, false, 0, false);
        InsertData('1319', XNonVATliablesalesExportTxt, 2, '', 0, '', '', '1310..1318', 0, 0, true, 1, false);
        InsertData('1320', XNonVATliablesalesDenmarkTxt, 1, '', 2, DemoDataSetup.DomesticCode(), DemoDataSetup.NoVATCode(), '', 2, 0, false, 0, false);
        InsertData('1329', XNonVATliablesalesDenmarkTxt, 2, '', 0, '', '', '1320..1328', 0, 0, true, 1, false);
    end;
}

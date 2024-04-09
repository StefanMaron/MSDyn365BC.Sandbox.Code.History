codeunit 101256 "Create VAT Statement Line"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            if "Company Type" = "Company Type"::"Sales Tax" then
                exit;
            if ("Data Type" = "Data Type"::Evaluation) or ("Data Type" = "Data Type"::Standard) then begin
                // Trial and Evaluation Company
                InsertData('001', VATStatLine001Txt, 2, '', 0, '', '', '020|030', 0, 0, true, 0, false);
                InsertData('002', VATStatLine002Txt, 2, '', 0, '', '', '090|100', 0, 0, true, 0, false);
                InsertData('', VATStatLine002aTxt, 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('003', VATStatLine003Txt, 2, '', 0, '', '', '001|002', 0, 0, true, 0, false);
                InsertData('004', VATStatLine004Txt, 2, '', 0, '', '', '040|050|070|080', 0, 0, true, 1, false);
                InsertData('', VATStatLine004aTxt, 3, '', 0, '', '', '', 0, 0, true, 1, false);
                InsertData('005', VATStatLine005Txt, 2, '', 0, '', '', '020|030|070|080', 0, 0, true, 0, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('006', VATStatLine006Txt, 2, '', 0, '', '', '110|120|170|180|008', 0, 0, true, 1, false);
                InsertData('', VATStatLine006aTxt, 3, '', 0, '', '', '', 0, 0, true, 1, false);
                InsertData('007', VATStatLine007Txt, 2, '', 0, '', '', '210|220|270|280|009', 0, 0, true, 0, false);
                InsertData('', VATStatLine007aTxt, 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('008', VATStatLine008Txt, 2, '', 0, '', '', '140|150', 0, 0, true, 1, false);
                InsertData('', VATStatLine008aTxt, 3, '', 0, '', '', '', 0, 0, true, 1, false);
                InsertData('009', VATStatLine009Txt, 2, '', 0, '', '', '240|250', 0, 0, true, 0, false);
                InsertData('', VATStatLine009aTxt, 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('', VATStatLine009bTxt, 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('', VATStatLine009cTxt, 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('011', StrSubstNo(SalesTxt, GoodsVATText, ''), 1, '', 2, DomesticCode, GoodsVATCode, '', 1, 1, false, 0, false);
                InsertData(
                  '012', StrSubstNo(SalesTxt, GoodsVATText, XFullTxt), 1, '', 2, DomesticCode, FullGoodsVATCode, '', 1, 1, false, 0, false);
                InsertData('020', StrSubstNo(SalesTxt, GoodsVATText, XTotalTxt), 2, '', 0, '', '', '011..019', 0, 0, true, 0, false);
                InsertData('021', StrSubstNo(SalesTxt, ServicesVATText, ''), 1, '', 2, DomesticCode, ServicesVATCode, '', 1, 1, false, 0, false);
                InsertData(
                  '022', StrSubstNo(SalesTxt, ServicesVATText, XFullTxt), 1, '', 2, DomesticCode, FullServicesVATCode, '', 1, 1, false, 0, false);
                InsertData('030', StrSubstNo(SalesTxt, ServicesVATText, XTotalTxt), 2, '', 0, '', '', '021..029', 0, 0, true, 0, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('031', StrSubstNo(XOnEUAcqTxt, GoodsVATText), 1, '', 1, EUCode, GoodsVATCode, '', 1, 1, false, 1, false);
                InsertData('040', StrSubstNo(XOnEUAcqTotalTxt, GoodsVATText), 2, '', 0, '', '', '031..039', 0, 0, true, 1, false);
                InsertData('041', StrSubstNo(XOnEUAcqTxt, ServicesVATText), 1, '', 1, EUCode, ServicesVATCode, '', 1, 1, false, 1, false);
                InsertData('050', StrSubstNo(XOnEUAcqTotalTxt, ServicesVATText), 2, '', 0, '', '', '041..049', 0, 0, true, 1, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData(
                  '061', StrSubstNo(PurchaseTxt, XVAT, GoodsVATText, XDomestic, ''), 1, '', 1, DomesticCode, GoodsVATCode, '', 1, 1, false, 1, false);
                InsertData('062', StrSubstNo(PurchaseTxt, XVAT, GoodsVATText, XFullTxt, XDomestic),
                  1, '', 1, DomesticCode, FullGoodsVATCode, '', 1, 1, false, 1, false);
                InsertData('070', StrSubstNo(PurchaseTxt, GoodsVATText, XDomestic, XTotal, ''), 2, '', 0, '', '', '061..069', 0, 0, true, 1, false);
                InsertData(
                  '071', StrSubstNo(PurchaseTxt, XVAT, ServicesVATText, XDomestic, ''), 1, '', 1, DomesticCode, ServicesVATCode, '', 1, 1, false, 1, false);
                InsertData('072', StrSubstNo(PurchaseTxt, ServicesVATText, XDomestic, XTotal, XFullTxt), 1, '', 1, DomesticCode,
                  FullServicesVATCode, '', 1, 1, false, 1, false);
                InsertData('080', StrSubstNo(PurchaseTxt, ServicesVATText, XDomestic, XTotalTxt, ''), 2, '', 0, '', '', '071..079', 0, 0, true, 1, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('081', StrSubstNo(XOnEUAcqTxt, GoodsVATText), 1, '', 1, EUCode, GoodsVATCode, '', 1, 0, false, 1, false);
                InsertData('090', StrSubstNo(XOnEUAcqTotalTxt, GoodsVATText), 2, '', 0, '', '', '081..089', 0, 0, false, 1, false);
                InsertData('091', StrSubstNo(XOnEUAcqTxt, ServicesVATText), 1, '', 1, EUCode, ServicesVATCode, '', 1, 0, false, 1, false);
                InsertData('100', StrSubstNo(XOnEUAcqTotalTxt, ServicesVATText), 2, '', 0, '', '', '091..099', 0, 0, false, 1, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, false, 0, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('101', StrSubstNo(XValueOfDomesticSalesTxt, GoodsVATText, ''), 1, '', 2, DomesticCode, GoodsVATCode, '', 2, 0, false, 1, false);
                InsertData('110', StrSubstNo(XValueOfDomesticSalesTxt, GoodsVATText, XTotalTxt), 2, '', 0, '', '', '101..109', 0, 0, true, 1, false);
                InsertData(
                  '111', StrSubstNo(XValueOfDomesticSalesTxt, ServicesVATText, ''), 1, '', 2, DomesticCode, ServicesVATCode, '', 2, 0, false, 1, false);
                InsertData('120', StrSubstNo(XValueOfDomesticSalesTxt, ServicesVATText, XTotalTxt), 2, '', 0, '', '', '111..119', 0, 0, true, 1, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('131', StrSubstNo(XValueofEUSuppliesTxt, GoodsVATText, ''), 1, '', 2, EUCode, GoodsVATCode, '', 2, 0, false, 1, false);
                InsertData('140', StrSubstNo(XValueofEUSuppliesTxt, GoodsVATText, XTotalTxt), 2, '', 0, '', '', '131..139', 0, 0, true, 1, false);
                InsertData('141', StrSubstNo(XValueofEUSuppliesTxt, ServicesVATText, ''), 1, '', 2, EUCode, ServicesVATCode, '', 2, 0, false, 1, false);
                InsertData('150', StrSubstNo(XValueofEUSuppliesTxt, ServicesVATText, XTotalTxt), 2, '', 0, '', '', '141..149', 0, 0, true, 1, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('161', StrSubstNo(XValueofOverseasSalesTxt, GoodsVATText, ''), 1, '', 2, XExportTxt, GoodsVATCode, '', 2, 0, false, 1, false);
                InsertData('170', StrSubstNo(XValueofOverseasSalesTxt, GoodsVATText, XTotalTxt), 2, '', 0, '', '', '161..169', 0, 0, true, 1, false);
                InsertData(
                  '171', StrSubstNo(XValueofOverseasSalesTxt, ServicesVATText, ''), 1, '', 2, XExportTxt, ServicesVATCode, '', 2, 0, false, 1, false);
                InsertData(
                  '180', StrSubstNo(XValueofOverseasSalesTxt, ServicesVATText, XTotalTxt), 2, '', 0, '', '', '171..179', 0, 0, true, 1, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('190', VATStatLine190Txt, 1, '', 2, DomesticCode, '', '', 2, 0, true, 1, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData(
                  '201', StrSubstNo(XValueofDomesticPurchasesTxt, GoodsVATText, ''), 1, '', 1, DomesticCode, GoodsVATCode, '', 2, 0, false, 0, false);
                InsertData(
                  '210', StrSubstNo(XValueofDomesticPurchasesTxt, GoodsVATText, XTotalTxt), 2, '', 0, '', '', '201..209', 0, 0, true, 0, false);
                InsertData(
                  '211', StrSubstNo(XValueofDomesticPurchasesTxt, ServicesVATText, ''), 1, '', 1, DomesticCode, ServicesVATCode, '', 2, 0, false,
                  0, false);
                InsertData(
                  '220', StrSubstNo(XValueofDomesticPurchasesTxt, ServicesVATText, XTotalTxt), 2, '', 0, '', '', '211..219', 0, 0, true, 0, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('231', StrSubstNo(XValueofEUAcquisitionsTxt, GoodsVATText, ''), 1, '', 1, EUCode, GoodsVATCode, '', 2, 0, false, 0, false);
                InsertData('240', StrSubstNo(XValueofEUAcquisitionsTxt, GoodsVATText, XTotal), 2, '', 0, '', '', '231..239', 0, 0, true, 0, false);
                InsertData(
                  '241', StrSubstNo(XValueofEUAcquisitionsTxt, ServicesVATText, ''), 1, '', 1, EUCode, ServicesVATCode, '', 2, 0, false, 0, false);
                InsertData(
                  '250', StrSubstNo(XValueofEUAcquisitionsTxt, ServicesVATText, XTotalTxt), 2, '', 0, '', '', '241..249', 0, 0, true, 0, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData(
                  '261', StrSubstNo(XValueofOverseasPurchasesTxt, GoodsVATText, ''), 1, '', 1, XExportTxt, GoodsVATCode, '', 2, 0, false, 0, false);
                InsertData(
                  '270', StrSubstNo(XValueofOverseasPurchasesTxt, GoodsVATText, XTotalTxt), 2, '', 0, '', '', '261..269', 0, 0, true, 0, false);
                InsertData(
                  '271', StrSubstNo(XValueofOverseasPurchasesTxt, ServicesVATText, ''), 1, '', 1, XExportTxt, ServicesVATCode, '', 2, 0, false, 0, false);
                InsertData(
                  '280', StrSubstNo(XValueofOverseasPurchasesTxt, ServicesVATText, XTotalTxt), 2, '', 0, '', '', '271..279', 0, 0, true, 0, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('290', VATStatLine290Txt, 1, '', 1, DomesticCode, NoVATCode, '', 2, 0, true, 0, false);
            end else begin
                InsertData(
                  '1010', StrSubstNo(XSalesVATPERCENToutgoing, GoodsVATText), 1, '', 2, DomesticCode, GoodsVATCode, '', 1, 0, false, 1, false);
                InsertData(
                  '1020', StrSubstNo(XSalesVATPERCENToutgoing, ServicesVATText), 1, '', 2, DomesticCode, ServicesVATCode, '', 1, 0, false, 1, false);
                InsertData(
                  '1050', StrSubstNo(XVATPERCENTonEUPurchasesetc, GoodsVATText), 1, '', 1, EUCode, GoodsVATCode, '', 1, 1, false, 1, false);
                InsertData(
                  '1060', StrSubstNo(XVATPERCENTonEUPurchasesetc, ServicesVATText), 1, '', 1, EUCode, ServicesVATCode, '', 1, 1, false, 1, false);
                if "Reduced VAT Rate" > 0 then begin
                    InsertData(
                      '1030', StrSubstNo(XSalesVATPERCENToutgoing, ReducedVATText), 1, '', 2, DomesticCode, ReducedVATCode, '', 1, 0, false, 1, false);
                    InsertData(
                      '1070', StrSubstNo(XVATPERCENTonEUPurchasesetc, ReducedVATText), 1, '', 1, EUCode, ReducedVATCode, '', 1, 1, false, 1, false);
                end;
                InsertData('', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('1099', XTotal, 2, '', 0, '', '', '1010..1090', 0, 0, true, 1, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData(
                  '1110', StrSubstNo(XPurchaseVATPERCENTDomestic, GoodsVATText), 1, '', 1, DomesticCode, GoodsVATCode, '', 1, 0, false, 0, false);
                InsertData(
                  '1120', StrSubstNo(XPurchaseVATPERCENTDomestic, ServicesVATText), 1, '', 1, DomesticCode, ServicesVATCode, '', 1, 0, false, 0, false);
                InsertData(
                  '1150', StrSubstNo(XPurchaseVATPERCENTEU, GoodsVATText), 1, '', 1, EUCode, GoodsVATCode, '', 1, 0, false, 0, false);
                InsertData(
                  '1160', StrSubstNo(XPurchaseVATPERCENTEU, ServicesVATText), 1, '', 1, EUCode, ServicesVATCode, '', 1, 0, false, 0, false);
                if "Reduced VAT Rate" > 0 then begin
                    InsertData(
                      '1130', StrSubstNo(XPurchaseVATPERCENTDomestic, ReducedVATText), 1, '', 1, DomesticCode, ReducedVATCode, '', 1, 0, false, 0, false);
                    InsertData(
                      '1170', StrSubstNo(XPurchaseVATPERCENTEU, ReducedVATText), 1, '', 1, EUCode, ReducedVATCode, '', 1, 0, false, 0, false);
                end;
                InsertData('1179', XPurchaseVATingoing, 2, '', 0, '', '', '1110..1170', 0, 0, true, 1, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('1180', XFuelTax, 0, CA.Convert('995710'), 0, '', '', '', 0, 0, true, 1, false);
                InsertData('1181', XElectricityTax, 0, CA.Convert('995720'), 0, '', '', '', 0, 0, true, 1, false);
                InsertData('1182', XNaturalGasTax, 0, CA.Convert('995730'), 0, '', '', '', 0, 0, true, 1, false);
                InsertData('1183', XCoalTax, 0, CA.Convert('995740'), 0, '', '', '', 0, 0, true, 1, false);
                InsertData('1184', XCO2Tax, 0, CA.Convert('995750'), 0, '', '', '', 0, 0, true, 1, false);
                InsertData('1185', XWaterTax, 0, CA.Convert('995760'), 0, '', '', '', 0, 0, true, 1, false);
                InsertData('1189', XTotalTaxes, 2, '', 0, '', '', '1180..1188', 0, 0, true, 1, false);
                InsertData('', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('1199', XTotalDeductions, 2, '', 0, '', '', '1159|1189', 0, 0, true, 1, false);
                InsertData('', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('', XVATPayable, 2, '', 0, '', '', '1099|1199', 0, 0, true, 1, false);
                InsertData('', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData(
                  '1210', StrSubstNo(XValueofEUPurchasesPERCENT, GoodsVATText), 1, '', 1, EUCode, GoodsVATCode, '', 2, 0, false, 0, false);
                InsertData(
                  '1220', StrSubstNo(XValueofEUPurchasesPERCENT, ServicesVATText), 1, '', 1, EUCode, ServicesVATCode, '', 2, 0, false, 0, false);
                if "Reduced VAT Rate" > 0 then
                    InsertData(
                      '1230', StrSubstNo(XValueofEUPurchasesPERCENT, ReducedVATText), 1, '', 1, EUCode, ReducedVATCode, '', 2, 0, false, 0, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData(
                  '1240', StrSubstNo(XValueofEUSalesPERCENT, GoodsVATText), 1, '', 2, EUCode, GoodsVATCode, '', 2, 0, false, 1, false);
                InsertData(
                  '1250', StrSubstNo(XValueofEUSalesPERCENT, ServicesVATText), 1, '', 2, EUCode, ServicesVATCode, '', 2, 0, false, 1, false);
                if "Reduced VAT Rate" > 0 then
                    InsertData('1260', StrSubstNo(XValueofEUSalesPERCENT, ReducedVATText), 1, '', 2, EUCode, ReducedVATCode, '', 2, 0, false, 1, false);
                InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                InsertData('1310', XNonVATliablesalesOverseas, 1, '', 2, ExportCode, GoodsVATCode, '', 2, 0, false, 0, false);
                InsertData('1320', XNonVATliablesalesOverseas, 1, '', 2, ExportCode, ServicesVATCode, '', 2, 0, false, 0, false);
                if "Reduced VAT Rate" > 0 then
                    InsertData('1330', XNonVATliablesalesOverseas, 1, '', 2, ExportCode, ReducedVATCode, '', 2, 0, false, 0, false);
                InsertData('', XNonVATliablesalesOverseas, 2, '', 0, '', '', '1310..1330', 0, 0, true, 1, false);
                InsertData('1340', XNonVATliablesalesDomestic, 1, '', 2, DomesticCode, NoVATCode, '', 2, 0, false, 0, false);
                InsertData('', XNonVATliablesalesDomestic, 2, '', 0, '', '', '1340..1348', 0, 0, true, 1, false);
            end;
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        CA: Codeunit "Make Adjustments";
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
        VATStatLine001Txt: Label 'VAT due in the period on sales and other outputs';
        VATStatLine002Txt: Label 'VAT due in the period on acquisitions from other';
        VATStatLine002aTxt: Label 'member states of the EC';
        VATStatLine003Txt: Label 'Total VAT due';
        VATStatLine004Txt: Label 'VAT reclaimed in the period on purchases and other';
        VATStatLine004aTxt: Label 'inputs (including acquisitions from the EC)';
        VATStatLine005Txt: Label 'Net VAT to be paid (+) or to be reclaimed (-)';
        VATStatLine006Txt: Label 'Total value of sales and all other outputs ';
        VATStatLine006aTxt: Label 'excluding any VAT';
        VATStatLine007Txt: Label 'Total value of purchases and all other inputs ';
        VATStatLine007aTxt: Label 'excluding any VAT';
        VATStatLine008Txt: Label 'Total value of all supplies of goods and related';
        VATStatLine008aTxt: Label 'costs, excluding any VAT to other EC member states';
        VATStatLine009Txt: Label 'total value of all acquisitions of goods and ';
        VATStatLine009aTxt: Label 'related costs, excluding any VAT, from other EC ';
        VATStatLine009bTxt: Label 'member states';
        VATStatLine009cTxt: Label '================================================';
        SalesTxt: Label 'Sales %1 %2', Comment = '%1 = VAT code,%2 = Full or total';
        PurchaseTxt: Label 'Purchase %1 %2 %3 %4', Comment = '%1 = VAT,%2 = VAT Rate,%3 = Total or Full,%4 = Domestic or Foreign';
        VATStatLine190Txt: Label 'Value of non-VAT liable sales';
        VATStatLine290Txt: Label 'Value of non-VAT liable purchases';
        XFullTxt: Label 'FULL', Comment = 'No need to translate';
        XTotalTxt: Label 'total';
        XOnEUAcqTxt: Label '%1 on EU Acquisitions etc.', Comment = '%1 = VAT Rate';
        XOnEUAcqTotalTxt: Label '%1 on EU Acquisitions etc. total', Comment = '%1 = VAT Rate';
        XDomestic: Label 'Domestic';
        XValueOfDomesticSalesTxt: Label 'Value of Domestic Sales %1 %2', Comment = '%1 = VAT Rate,%2 = defines if line shows total amount';
        XValueofEUSuppliesTxt: Label 'Value of EU Supplies %1 %2', Comment = '%1 = VAT Rate,%2 = defines if line shows total amount';
        XValueofOverseasSalesTxt: Label 'Value of Overseas Sales %1 %2', Comment = '%1 = VAT Rate,%2 = defines if line shows total amount';
        XValueofDomesticPurchasesTxt: Label 'Value of Domestic Purchases %1 %2', Comment = '%1 = VAT Rate,%2 = defines if line shows total amount';
        XValueofEUAcquisitionsTxt: Label 'Value of EU Acquisitions %1 %2', Comment = '%1 = VAT Rate,%2 = defines if line shows total amount';
        XValueofOverseasPurchasesTxt: Label 'Value of Overseas Purchases %1 %2', Comment = '%1 = VAT Rate,%2 = defines if line shows total amount';
        XExportTxt: Label 'EXPORT', Comment = 'No need to translate';

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
}


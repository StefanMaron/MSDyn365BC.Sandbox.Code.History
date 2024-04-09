codeunit 101256 "Create VAT Statement Line"
{

    trigger OnRun()
    begin
        exit;

        "Demonstration Data Setup".Get();
        case "Demonstration Data Setup"."Company Type" of
            "Demonstration Data Setup"."Company Type"::VAT:
                begin
                    InsertData('1010', XSalesVAT25PERCENToutgoing, 1, '', 2, XNATIONAL, XVAT25, '', 1, 0, false, 1, false);
                    InsertData('1019', XSalesVAT25PERCENToutgoing, 2, '', 0, '', '', '1010..1018', 0, 0, true, 1, false);
                    InsertData('1020', XSalesVAT10PERCENToutgoing, 1, '', 2, XNATIONAL, XVAT10, '', 1, 0, false, 1, false);
                    InsertData('1029', XSalesVAT10PERCENToutgoing, 2, '', 0, '', '', '1020..1028', 0, 0, true, 1, false);
                    InsertData('1030', XVAT25PERCENTonEUPurchasesetc, 1, '', 1, XEU, XVAT25, '', 1, 1, false, 1, false);
                    InsertData('1039', XVAT25PERCENTonEUPurchasesetc, 2, '', 0, '', '', '1030..1038', 0, 0, true, 1, false);
                    InsertData('1040', XVAT10PERCENTonEUPurchasesetc, 1, '', 1, XEU, XVAT10, '', 1, 1, false, 1, false);
                    InsertData('1049', XVAT10PERCENTonEUPurchasesetc, 2, '', 0, '', '', '1040..1048', 0, 0, true, 1, false);
                    InsertData('', '--------------------------------------------------', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                    InsertData('1099', XTotal, 2, '', 0, '', '', '1019|1029|1039|1049', 0, 0, true, 1, false);
                    InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                    InsertData('1110', XPurchaseVAT25PERCENTDomestic, 1, '', 1, XNATIONAL, XVAT25, '', 1, 0, false, 0, false);
                    InsertData('1119', XPurchaseVAT25PERCENTDomestic, 2, '', 0, '', '', '1110..1118', 0, 0, true, 1, false);
                    InsertData('1120', XPurchaseVAT10PERCENTDomestic, 1, '', 1, XNATIONAL, XVAT10, '', 1, 0, false, 0, false);
                    InsertData('1129', XPurchaseVAT10PERCENTDomestic, 2, '', 0, '', '', '1120..1128', 0, 0, true, 1, false);
                    InsertData('1130', XPurchaseVAT25PERCENTEU, 1, '', 1, XEU, XVAT25, '', 1, 0, false, 0, false);
                    InsertData('1139', XPurchaseVAT25PERCENTEU, 2, '', 0, '', '', '1130..1138', 0, 0, true, 1, false);
                    InsertData('1140', XPurchaseVAT10PERCENTEU, 1, '', 1, XEU, XVAT10, '', 1, 0, false, 0, false);
                    InsertData('1149', XPurchaseVAT10PERCENTEU, 2, '', 0, '', '', '1140..1148', 0, 0, true, 1, false);
                    InsertData('1159', XPurchaseVATingoing, 2, '', 0, '', '', '1119|1129|1139|1149', 0, 0, true, 1, false);
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
                    InsertData('1210', XValueofEUPurchases25PERCENT, 1, '', 1, XEU, XVAT25, '', 2, 0, false, 0, false);
                    InsertData('', XValueofEUPurchases25PERCENT, 2, '', 0, '', '', '1210..1218', 0, 0, true, 0, false);
                    InsertData('1220', XValueofEUPurchases10PERCENT, 1, '', 1, XEU, XVAT10, '', 2, 0, false, 0, false);
                    InsertData('', XValueofEUPurchases10PERCENT, 2, '', 0, '', '', '1220..1228', 0, 0, true, 0, false);
                    InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                    InsertData('1230', XValueofEUSales, 1, '', 2, XEU, XVAT25, '', 2, 0, false, 1, false);
                    InsertData('', XValueofEUSales25PERCENT, 2, '', 0, '', '', '1230..1238', 0, 0, true, 1, false);
                    InsertData('1240', XValueofEUSales, 1, '', 2, XEU, XVAT10, '', 2, 0, false, 1, false);
                    InsertData('', XValueofEUSales10PERCENT, 2, '', 0, '', '', '1240..1248', 0, 0, true, 1, false);
                    InsertData('', '', 3, '', 0, '', '', '', 0, 0, true, 0, false);
                    InsertData('1310', XNonVATliablesalesOverseas, 1, '', 2, XEXPORT, XVAT25, '', 2, 0, false, 0, false);
                    InsertData('1312', XNonVATliablesalesOverseas, 1, '', 2, XEXPORT, XVAT10, '', 2, 0, false, 0, false);
                    InsertData('', XNonVATliablesalesOverseas, 2, '', 0, '', '', '1310..1318', 0, 0, true, 1, false);
                    InsertData('1320', XNonVATliablesalesDomestic, 1, '', 2, XNATIONAL, XNOVAT, '', 2, 0, false, 0, false);
                    InsertData('', XNonVATliablesalesDomestic, 2, '', 0, '', '', '1320..1328', 0, 0, true, 1, false);
                end;
        end;
    end;

    var
        "Demonstration Data Setup": Record "Demo Data Setup";
        "Line No.": Integer;
        CA: Codeunit "Make Adjustments";
        XSalesVAT25PERCENToutgoing: Label 'Sales VAT 25 % (outgoing)';
        XNATIONAL: Label 'NATIONAL';
        XVAT25: Label 'VAT25';
        XSalesVAT10PERCENToutgoing: Label 'Sales VAT 10 % (outgoing)';
        XVAT10: Label 'VAT10';
        XVAT25PERCENTonEUPurchasesetc: Label 'VAT 25 % on EU Purchases etc.';
        XVAT10PERCENTonEUPurchasesetc: Label 'VAT 10 % on EU Purchases etc.';
        XEU: Label 'EU';
        XTotal: Label 'Total';
        XPurchaseVAT25PERCENTDomestic: Label 'Purchase VAT 25 % Domestic';
        XPurchaseVAT10PERCENTDomestic: Label 'Purchase VAT 10 % Domestic';
        XPurchaseVAT25PERCENTEU: Label 'Purchase VAT 25 % EU';
        XPurchaseVAT10PERCENTEU: Label 'Purchase VAT 10 % EU';
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
        XValueofEUPurchases25PERCENT: Label 'Value of EU Purchases 25 %';
        XValueofEUPurchases10PERCENT: Label 'Value of EU Purchases 10 %';
        XValueofEUSales: Label 'Value of EU Sales';
        XValueofEUSales25PERCENT: Label 'Value of EU Sales25 %';
        XValueofEUSales10PERCENT: Label 'Value of EU Sales 10 %';
        XNonVATliablesalesOverseas: Label 'Non-VAT liable sales, Overseas';
        XNonVATliablesalesDomestic: Label 'Non-VAT liable sales, Domestic';
        XNOVAT: Label 'NO VAT';
        XEXPORT: Label 'EXPORT';
        XVAT: Label 'VAT';
        XDEFAULT: Label 'DEFAULT';

    procedure InsertData("Row No.": Code[10]; Description: Text[50]; Type: Option; "Account Totaling": Text[30]; "Gen. Posting Type": Option; "VAT Bus. Posting Group": Code[20]; "VAT Prod. Posting Group": Code[20]; "Row Totaling": Text[30]; "Amount Type": Option; "Calculate with": Option; Print: Boolean; "Print with": Option; "New Page": Boolean)
    var
        "VAT Statement Line": Record "VAT Statement Line";
    begin
        "VAT Statement Line".Init();
        "VAT Statement Line".Validate("Statement Template Name", XVAT);
        "VAT Statement Line".Validate("Statement Name", XDEFAULT);
        "Line No." := "Line No." + 10000;
        "VAT Statement Line".Validate("Line No.", "Line No.");
        "VAT Statement Line".Validate("Row No.", "Row No.");
        "VAT Statement Line".Validate(Description, Description);
        "VAT Statement Line".Validate(Type, Type);
        "VAT Statement Line".Validate("Account Totaling", "Account Totaling");
        "VAT Statement Line".Validate("Gen. Posting Type", "Gen. Posting Type");
        "VAT Statement Line".Validate("VAT Bus. Posting Group", "VAT Bus. Posting Group");
        "VAT Statement Line".Validate("VAT Prod. Posting Group", "VAT Prod. Posting Group");
        "VAT Statement Line".Validate("Row Totaling", "Row Totaling");
        "VAT Statement Line".Validate("Amount Type", "Amount Type");
        "VAT Statement Line".Validate("Calculate with", "Calculate with");
        "VAT Statement Line".Validate(Print, Print);
        "VAT Statement Line".Validate("Print with", "Print with");
        "VAT Statement Line".Validate("New Page", "New Page");
        "VAT Statement Line".Insert();
    end;
}


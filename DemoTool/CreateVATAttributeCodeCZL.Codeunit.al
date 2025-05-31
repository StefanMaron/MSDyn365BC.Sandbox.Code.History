codeunit 163538 "Create VAT Attribute Code CZL"
{
    trigger OnRun()
    begin
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-01D', StrSubstNo(XOutputtaxTxt, '001'), 'DAN23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-01Z', StrSubstNo(XTaxbaseTxt, '001'), 'OBRAT23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-02D', StrSubstNo(XOutputtaxTxt, '002'), 'DAN5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-02Z', StrSubstNo(XTaxbaseTxt, '002'), 'OBRAT5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-03D', StrSubstNo(XOutputtaxTxt, '003'), 'DAN_PZB23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-03Z', StrSubstNo(XTaxbaseTxt, '003'), 'P_ZB23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-04D', StrSubstNo(XOutputtaxTxt, '004'), 'DAN_PZB5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-04Z', StrSubstNo(XTaxbaseTxt, '004'), 'P_ZB5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-05D', StrSubstNo(XOutputtaxTxt, '005'), 'DAN_PSL23_E');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-05Z', StrSubstNo(XTaxbaseTxt, '005'), 'P_SL23_E');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-06D', StrSubstNo(XOutputtaxTxt, '006'), 'DAN_PSL5_E');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-06Z', StrSubstNo(XTaxbaseTxt, '006'), 'P_SL5_E');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-07D', StrSubstNo(XOutputtaxTxt, '007'), 'DAN_DZB23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-07Z', StrSubstNo(XTaxbaseTxt, '007'), 'DOV_ZB23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-08D', StrSubstNo(XOutputtaxTxt, '008'), 'DAN_DZB5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-08Z', StrSubstNo(XTaxbaseTxt, '008'), 'DOV_ZB5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-09D', StrSubstNo(XOutputtaxTxt, '009'), 'DAN_PDOP_NRG');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-09Z', StrSubstNo(XTaxbaseTxt, '009'), 'P_DOP_NRG');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-10D', StrSubstNo(XOutputtaxTxt, '010'), 'DAN_RPREN23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-10Z', StrSubstNo(XTaxbaseTxt, '010'), 'REZ_PREN23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-11D', StrSubstNo(XOutputtaxTxt, '011'), 'DAN_RPREN5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-11Z', StrSubstNo(XTaxbaseTxt, '011'), 'REZ_PREN5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-12D', StrSubstNo(XOutputtaxTxt, '012'), 'DAN_PSL23_Z');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-12Z', StrSubstNo(XTaxbaseTxt, '012'), 'P_SL23_Z');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-13D', StrSubstNo(XOutputtaxTxt, '013'), 'DAN_PSL5_Z');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-13Z', StrSubstNo(XTaxbaseTxt, '013'), 'P_SL5_Z');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-20Z', StrSubstNo(XTaxbaseTxt, '020'), 'DOD_ZB');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-21Z', StrSubstNo(XTaxbaseTxt, '021'), 'PLN_SLUZBY');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-22Z', StrSubstNo(XTaxbaseTxt, '022'), 'PLN_VYVOZ');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-23Z', StrSubstNo(XTaxbaseTxt, '023'), 'DOD_DOP_NRG');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-24Z', StrSubstNo(XTaxbaseTxt, '024'), 'PLN_ZASLANI');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-25Z', StrSubstNo(XTaxbaseTxt, '025'), 'PLN_REZ_PREN');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-26Z', StrSubstNo(XTaxbaseTxt, '026'), 'PLN_OST');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-30Z', StrSubstNo(XAcquisitionofgoodstaxbaseTxt, '030'), 'TRI_POZB');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-31Z', StrSubstNo(XDeliveryofgoodstaxbaseTxt, '031'), 'TRI_DOZB');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-32Z', StrSubstNo(XGoodsimporttaxbaseTxt, '032'), 'DOV_OSV');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-33D', StrSubstNo(XCreditortaxTxt, '033'), 'OPR_VERIT');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-34D', StrSubstNo(XDebtortaxTxt, '034'), 'OPR_DLUZ');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-40D', StrSubstNo(XInfullTxt, '040'), 'ODP_TUZ23_NAR');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-40K', StrSubstNo(XReduceddeductionTxt, '040'), 'ODP_TUZ23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-40Z', StrSubstNo(XTaxbaseTxt, '040'), 'PLN23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-41D', StrSubstNo(XInfullTxt, '041'), 'ODP_TUZ5_NAR');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-41K', StrSubstNo(XReduceddeductionTxt, '041'), 'ODP_TUZ5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-41Z', StrSubstNo(XTaxbaseTxt, '041'), 'PLN5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-42D', StrSubstNo(XInfullTxt, '042'), 'ODP_CU_NAR');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-42K', StrSubstNo(XReduceddeductionTxt, '042'), 'ODP_CU');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-42Z', StrSubstNo(XTaxbaseTxt, '042'), 'DOV_CU');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-43D', StrSubstNo(XInfullTxt, '043'), 'OD_ZDP23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-43K', StrSubstNo(XReduceddeductionTxt, '043'), 'ODKR_ZDP23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-43Z', StrSubstNo(XTaxbaseTxt, '043'), 'NAR_ZDP23');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-44D', StrSubstNo(XInfullTxt, '044'), 'OD_ZDP5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-44K', StrSubstNo(XReduceddeductionTxt, '044'), 'ODKR_ZDP5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-44Z', StrSubstNo(XTaxbaseTxt, '044'), 'NAR_ZDP5');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-45D', StrSubstNo(XInfullTxt, '045'), 'ODP_REZ_NAR');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-45K', StrSubstNo(XReduceddeductionTxt, '045'), 'ODP_REZIM');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-46D', StrSubstNo(XInfullTxt, '046'), 'ODP_SUM_NAR');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-46K', StrSubstNo(XReduceddeductionTxt, '046'), 'ODP_SUM_KR');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-47D', StrSubstNo(XInfullTxt, '047'), 'OD_MAJ');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-47K', StrSubstNo(XReduceddeductionTxt, '047'), 'ODKR_MAJ');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-47Z', StrSubstNo(XTaxbaseTxt, '047'), 'NAR_MAJ');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-50Z', StrSubstNo(XTaxbaseTxt, '050'), 'PLNOSV_KF');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-51B', StrSubstNo(XWithoutclaimondeductionTxt, '051'), 'PLNOSV_NKF');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-51S', StrSubstNo(XWithclaimondeductionTxt, '051'), 'PLN_NKF');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-52D', StrSubstNo(XDeductionTxt, '052'), 'ODP_UPRAV_KF');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-52K', StrSubstNo(XCoefficientTxt, '052'), 'KOEF_P20_NOV');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-53D', StrSubstNo(XDeducationchangeTxt, '053'), 'VYPOR_ODP');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-53K', StrSubstNo(XSettlementcoefficientTxt, '53'), 'KOEF_P20_VYPOR');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-60D', StrSubstNo(XTaxTxt, '060'), 'UPRAV_ODP');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-61D', StrSubstNo(XTaxTxt, '061'), 'DAN_VRAC');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-62D', StrSubstNo(XTaxTxt, '062'), 'DAN_ZOCELK');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-63D', StrSubstNo(XTaxTxt, '063'), 'ODP_ZOCELK');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-64D', StrSubstNo(XTaxTxt, '064'), 'DANO_DA');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-65D', StrSubstNo(XTaxTxt, '065'), 'DANO_NO');
        InsertData(CreateVATStatementName.GetVAT('XVAT'), 'DP3-66D', StrSubstNo(XTaxTxt, '066'), 'DANO');
    end;

    var
        CreateVATStatementName: Codeunit "Create VAT Statement Name";
        XOutputtaxTxt: Label 'l. %1 - Output tax';
        XTaxbaseTxt: Label 'l. %1 - Tax base';
        XAcquisitionofgoodstaxbaseTxt: Label 'l. %1 - Acquisition of goods, tax base';
        XDeliveryofgoodstaxbaseTxt: Label 'l. %1 - Delivery of goods, tax base';
        XGoodsimporttaxbaseTxt: Label 'l. %1 - Goods import, tax base';
        XCreditortaxTxt: Label 'l. %1 - Creditor, tax';
        XDebtortaxTxt: Label 'l. %1 - Debtor, tax';
        XInfullTxt: Label 'l. %1 - In full';
        XReduceddeductionTxt: Label 'l. %1 - Reduced deduction';
        XWithoutclaimondeductionTxt: Label 'l. %1 - Without claim on deduction';
        XWithclaimondeductionTxt: Label 'l. %1 - With claim on deduction';
        XDeductionTxt: Label 'l. %1 - Deduction';
        XCoefficientTxt: Label 'l. %1 - Coefficient %';
        XDeducationchangeTxt: Label 'l. %1 - Deducation change';
        XSettlementcoefficientTxt: Label 'l. %1 - Settlement coefficient';
        XTaxTxt: Label 'l. %1 - Tax';

    local procedure InsertData(VATStatementTemplateName: Code[10]; Code: Code[20]; Description: Text[50]; XmlCode: Code[20])
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
    begin
        if VATAttributeCodeCZL.Get(VATStatementTemplateName, Code) then
            exit;
        VATAttributeCodeCZL.Init();
        VATAttributeCodeCZL.Validate("VAT Statement Template Name", VATStatementTemplateName);
        VATAttributeCodeCZL.Validate(Code, Code);
        VATAttributeCodeCZL.Validate(Description, Description);
        VATAttributeCodeCZL.Validate("XML Code", XmlCode);
        VATAttributeCodeCZL.Insert();
    end;
}

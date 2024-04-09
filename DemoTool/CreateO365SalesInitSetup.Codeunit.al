#if not CLEAN21
codeunit 122100 "Create O365 Sales Init. Setup"
{
    ObsoleteReason = 'Microsoft Invoicing has been discontinued.';
    ObsoleteState = Pending;
    ObsoleteTag = '21.0';

    trigger OnRun()
    var
        O365SalesInitialSetup: Record "O365 Sales Initial Setup";
        CustomerConfigTemplateHeader: Record "Config. Template Header";
        ItemConfigTemplateHeader: Record "Config. Template Header";
        NoSeries: Record "No. Series";
        DemoDataSetup: Record "Demo Data Setup";
        CreateNoSeries: Codeunit "Create No. Series";
        CreateCustomerTemplate: Codeunit "Create Customer Template";
        CreateVATBusPostingGr: Codeunit "Create VAT Bus. Posting Gr.";
        CreateVATProdPostingGr: Codeunit "Create VAT Prod. Posting Gr.";
    begin
        CustomerConfigTemplateHeader.SetRange(Description, CreateCustomerTemplate.GetCustomerTemplateDescriptionCashCustomer);
        if CustomerConfigTemplateHeader.FindFirst() then;
        ItemConfigTemplateHeader.SetRange(Description, XDefaultItemTemplateDescription);
        if ItemConfigTemplateHeader.FindFirst() then;
        DemoDataSetup.Get();

        with O365SalesInitialSetup do begin
            Init();
            Validate("Payment Reg. Template Name", XPaymentTxt);
            Validate("Payment Reg. Batch Name", XCashTxt);
            Validate("Default Customer Template", CustomerConfigTemplateHeader.Code);
            Validate("Default Item Template", ItemConfigTemplateHeader.Code);
            Validate("Default Payment Method Code", XBANK);
            Validate("Default Payment Terms Code", X14DAYS);
            Validate("Tax Type", DemoDataSetup."Company Type");
            Validate("C2Graph Endpoint", StrSubstNo(GraphUrlTxt, '{SHAREDCONTACTS}'));
            Validate("Engage Endpoint", EngageUrlTxt);
            Validate("Coupons Integration Enabled", true);
            if DemoDataSetup."Company Type" = DemoDataSetup."Company Type"::VAT then begin
                Validate("Default VAT Bus. Posting Group", CreateVATBusPostingGr.GetDomesticVATGroup);
                Validate("Normal VAT Prod. Posting Gr.", CreateVATProdPostingGr.GetNormalVATProdPostingGroup);
                Validate("Reduced VAT Prod. Posting Gr.", CreateVATProdPostingGr.GetReducedVATProdPostingGroup);
                Validate("Zero VAT Prod. Posting Gr.", CreateVATProdPostingGr.GetNoVATVATProdPostingGroup);
            end;

            if not NoSeries.Get(XDraftInvoice) then
                CreateNoSeries.InitBaseSeries(
                  "Sales Invoice No. Series", XDraftInvoice,
                  XDraftInvoiceDescription,
                  XDraftInvNoSeriesPrefixTxt + '00001',
                  XDraftInvNoSeriesPrefixTxt + '99999', '',
                  XDraftInvNoSeriesPrefixTxt + '99899', 1);

            if not NoSeries.Get(XPostedInvoice) then
                CreateNoSeries.InitBaseSeries(
                  "Posted Sales Inv. No. Series", XPostedInvoice,
                  XPostedInvoiceDescription, '00001', '99999', '', '99899', 1);

            if not NoSeries.Get(XQuote) then
                CreateNoSeries.InitBaseSeries(
                  "Sales Quote No. Series", XQuote,
                  XQuoteDescription,
                  XQuoteNoSeriesPrefixTxt + '00001',
                  XQuoteNoSeriesPrefixTxt + '99999', '',
                  XQuoteNoSeriesPrefixTxt + '99899', 1);

            Insert(true);
        end;
    end;

    var
        XCashTxt: Label 'CASH', Comment = 'Cash';
        XPaymentTxt: Label 'PAYMENT', Comment = 'Payment';
        XDefaultItemTemplateDescription: Label 'Service';
        XBANK: Label 'BANK', Comment = 'Bank payment type code';
        X14DAYS: Label '14 DAYS';
        XDraftInvoice: Label 'D-INV';
        XPostedInvoice: Label 'D-INV+';
        XQuote: Label 'D-QUO', Comment = 'Code, caps, max 10 char.';
        XDraftInvoiceDescription: Label 'Draft Invoice';
        XPostedInvoiceDescription: Label 'Posted Invoice';
        XQuoteDescription: Label 'Estimate';
        XQuoteNoSeriesPrefixTxt: Label 'E-', Comment = 'A one-letter prefix followed by a ''-'', abbreviating ''Estimate''';
        XDraftInvNoSeriesPrefixTxt: Label 'D-', Comment = 'A one-letter prefix followed by a ''-'', abbreviating ''Draft Invoice''';
        GraphUrlTxt: Label 'outlook.office365.com/SmallBusiness/api/v1/users(''%1'')/Activities', Locked = true;
        EngageUrlTxt: Label 'engageapi.office.com', Locked = true;
}
#endif

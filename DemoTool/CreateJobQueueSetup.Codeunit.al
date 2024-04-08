codeunit 117081 "Create Job Queue Setup"
{

    trigger OnRun()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        InsertJobQueueCategory(GetSalesPostCategoryCode, Text006);
        InsertJobQueueCategory(GetPurchPostCategoryCode, Text008);
        InsertJobQueueCategory(GetJrnlPostPostCategoryCode, Text010);

        with SalesReceivablesSetup do
            if Get() then begin
                "Job Queue Category Code" := GetSalesPostCategoryCode;
                Modify();
            end;

        with PurchasesPayablesSetup do
            if Get() then begin
                "Job Queue Category Code" := GetPurchPostCategoryCode;
                Modify();
            end;

        with GeneralLedgerSetup do
            if Get() then begin
                "Job Queue Category Code" := GetJrnlPostPostCategoryCode();
                Modify();
            end;
    end;

    var
        Text005: Label 'SALESPOST', Comment = 'Must be max. 10 chars and no spacing.';
        Text006: Label 'Sales Posting';
        Text007: Label 'PURCHPOST', Comment = 'Must be max. 10 chars and no spacing.';
        Text008: Label 'Purchase Posting';
        Text009: Label 'JRNLPOST', Comment = 'Must be max. 10 chars and no spacing.';
        Text010: Label 'General Ledger Posting';

    procedure InsertJobQueueCategory(Name: Code[10]; Description: Text[30])
    var
        JobQueueCategory: Record "Job Queue Category";
    begin
        JobQueueCategory.Init();
        JobQueueCategory.Code := Name;
        JobQueueCategory.Description := Description;
        JobQueueCategory.Insert();
    end;

    procedure GetSalesPostCategoryCode(): Code[10]
    begin
        exit(CopyStr(Text005, 1, 10));
    end;

    procedure GetPurchPostCategoryCode(): Code[10]
    begin
        exit(CopyStr(Text007, 1, 10));
    end;

    procedure GetJrnlPostPostCategoryCode(): Code[10]
    begin
        exit(CopyStr(Text009, 1, 10));
    end;
}


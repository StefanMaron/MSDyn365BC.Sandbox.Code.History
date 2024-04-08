codeunit 101565 "Create Interaction Log Entry"
{

    trigger OnRun()
    begin
        with "Sales Shipment Header" do
            if Find('-') then
                repeat
                    SegManagement.LogDocument(
                      5, "No.", 0, 0, DATABASE::Customer, "Bill-to Customer No.", "Salesperson Code",
                      "Campaign No.", "Posting Description", '');
                    InteractionLogEntry.FindLast();
                    InteractionLogEntry.Date := "Posting Date";
                    InteractionLogEntry.Modify();
                until Next = 0;

        with "Sales Invoice Header" do
            if Find('-') then
                repeat
                    SegManagement.LogDocument(
                      4, "No.", 0, 0, DATABASE::Customer, "Bill-to Customer No.", "Salesperson Code",
                      "Campaign No.", "Posting Description", '');
                    InteractionLogEntry.FindLast();
                    InteractionLogEntry.Date := "Posting Date";
                    InteractionLogEntry.Modify();
                until Next = 0;

        with "Sales Cr.Memo Header" do
            if Find('-') then
                repeat
                    SegManagement.LogDocument(
                      6, "No.", 0, 0, DATABASE::Customer, "Bill-to Customer No.", "Salesperson Code",
                      "Campaign No.", "Posting Description", '');
                    InteractionLogEntry.FindLast();
                    InteractionLogEntry.Date := "Posting Date";
                    InteractionLogEntry.Modify();
                until Next = 0;

        with "Purch. Rcpt. Header" do
            if Find('-') then
                repeat
                    SegManagement.LogDocument(
                      15, "No.", 0, 0, DATABASE::Vendor, "Buy-from Vendor No.", "Purchaser Code",
                      '', "Posting Description", '');
                    InteractionLogEntry.FindLast();
                    InteractionLogEntry.Date := "Posting Date";
                    InteractionLogEntry.Modify();
                until Next = 0;
    end;

    var
        "Sales Shipment Header": Record "Sales Shipment Header";
        "Sales Invoice Header": Record "Sales Invoice Header";
        "Sales Cr.Memo Header": Record "Sales Cr.Memo Header";
        "Purch. Rcpt. Header": Record "Purch. Rcpt. Header";
        SegManagement: Codeunit SegManagement;
        InteractionLogEntry: Record "Interaction Log Entry";
        StatementLbl: Label 'Statement ';

    procedure CreateEvaluationData()
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        Contact: Record Contact;
        Customer: Record Customer;
    begin
        with SalesHeader do begin
            SetRange("Document Type", "Sales Document Type"::Order);
            if FindSet() then
                repeat
                    SegManagement.LogDocument(
                        3, "No.", 0, 0, Database::Customer, "Bill-to Customer No.", "Salesperson Code",
                        "Campaign No.", "Posting Description", '');
                    InteractionLogEntry.FindLast();
                    InteractionLogEntry.Date := "Posting Date";
                    InteractionLogEntry.Modify();
                until Next() = 0;
        end;

        with SalesHeader do begin
            SetRange("Document Type", "Sales Document Type"::Quote);
            if FindSet() then
                repeat
                    SegManagement.LogDocument(
                        1, "No.", "Doc. No. Occurrence", "No. of Archived Versions", Database::Contact, "Bill-to Contact No.",
                        "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.");
                    InteractionLogEntry.FindLast();
                    InteractionLogEntry.Date := "Posting Date";
                    InteractionLogEntry.Modify();
                until Next() = 0;
        end;

        with PurchaseHeader do begin
            SetRange("Document Type", "Purchase Document Type"::Order);
            if FindSet() then
                repeat
                    SegManagement.LogDocument(
                        13, "No.", 0, 0, Database::Vendor, "Buy-from Vendor No.", "Purchaser Code",
                        "Campaign No.", "Posting Description", '');
                    InteractionLogEntry.FindLast();
                    InteractionLogEntry.Date := "Posting Date";
                    InteractionLogEntry.Modify();
                until Next() = 0;
        end;

        with Contact do begin
            if FindSet() then
                repeat
                    SegManagement.LogDocument(17, '', 0, 0, Database::Contact, Contact."No.", '', '', '', '');
                    InteractionLogEntry.FindLast();
                    InteractionLogEntry.Date := WorkDate();
                    InteractionLogEntry.Modify();
                until Next() = 0;
        end;

        with Customer do begin
            if FindSet() then
                repeat
                    SegManagement.LogDocument(
                          7, Format(Customer."Last Statement No."), 0, 0, Database::Customer, Customer."No.",
                          Customer."Salesperson Code", '', StatementLbl, '');
                    InteractionLogEntry.FindLast();
                    InteractionLogEntry.Date := WorkDate();
                    InteractionLogEntry.Modify();
                until Next() = 0;
        end;
    end;
}


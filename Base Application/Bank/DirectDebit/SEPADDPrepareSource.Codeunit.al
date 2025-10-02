// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.DirectDebit;

using Microsoft.Bank.Payment;

/// <summary>
/// Prepares direct debit collection entry data for SEPA XML export by copying and organizing
/// eligible entries into a temporary structure for XMLPort processing.
/// </summary>
codeunit 1232 "SEPA DD-Prepare Source"
{
    TableNo = "Direct Debit Collection Entry";

    trigger OnRun()
    var
        DirectDebitCollectionEntry: Record "Direct Debit Collection Entry";
    begin
        DirectDebitCollectionEntry.CopyFilters(Rec);
        CopyLines(DirectDebitCollectionEntry, Rec);
    end;

    /// <summary>
    /// Copies eligible direct debit collection entries to a temporary table for processing.
    /// Filters entries by status (New or File Created) and populates the target temporary table.
    /// </summary>
    /// <param name="FromDirectDebitCollectionEntry">Source direct debit collection entries with applied filters.</param>
    /// <param name="ToDirectDebitCollectionEntry">Target temporary table to receive the filtered entries.</param>
    local procedure CopyLines(var FromDirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var ToDirectDebitCollectionEntry: Record "Direct Debit Collection Entry")
    begin
        if not FromDirectDebitCollectionEntry.IsEmpty() then begin
            FromDirectDebitCollectionEntry.SetFilter(Status, '%1|%2',
              FromDirectDebitCollectionEntry.Status::New, FromDirectDebitCollectionEntry.Status::"File Created");
            if FromDirectDebitCollectionEntry.FindSet() then
                repeat
                    ToDirectDebitCollectionEntry := FromDirectDebitCollectionEntry;
                    ToDirectDebitCollectionEntry.Insert();
                until FromDirectDebitCollectionEntry.Next() = 0
        end else
            CreateTempCollectionEntries(FromDirectDebitCollectionEntry, ToDirectDebitCollectionEntry);
    end;

    /// <summary>
    /// Creates temporary collection entries when no source entries are found.
    /// Allows customization through integration events for alternative data population strategies.
    /// </summary>
    /// <param name="FromDirectDebitCollectionEntry">Source entry record used as template for temporary entries.</param>
    /// <param name="ToDirectDebitCollectionEntry">Target temporary table to populate with generated entries.</param>
    local procedure CreateTempCollectionEntries(var FromDirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var ToDirectDebitCollectionEntry: Record "Direct Debit Collection Entry")
    var
        DirectDebitCollection: Record "Direct Debit Collection";
        LSVJnl: Record "LSV Journal";
        LSVJnlLine: Record "LSV Journal Line";
        DirectDebitCollectionNo: Integer;
        LSVJnlNo: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateTempCollectionEntries(FromDirectDebitCollectionEntry, ToDirectDebitCollectionEntry, IsHandled);
        if IsHandled then
            exit;

        DirectDebitCollectionNo := FromDirectDebitCollectionEntry.GetRangeMin("Direct Debit Collection No.");
        DirectDebitCollection.Get(DirectDebitCollectionNo);
        Evaluate(LSVJnlNo, DirectDebitCollection.Identifier);

        if LSVJnl.Get(LSVJnlNo) then begin
            ToDirectDebitCollectionEntry.Reset();
            LSVJnlLine.SetRange("LSV Journal No.", LSVJnlNo);
            if LSVJnlLine.FindSet() then
                repeat
                    ToDirectDebitCollectionEntry.Init();
                    ToDirectDebitCollectionEntry."Direct Debit Collection No." := DirectDebitCollectionNo;
                    ToDirectDebitCollectionEntry."Entry No." := LSVJnlLine."Line No.";
                    ToDirectDebitCollectionEntry.Validate("Customer No.", LSVJnlLine."Customer No.");
                    ToDirectDebitCollectionEntry.Validate("Applies-to Entry No.", LSVJnlLine."Cust. Ledg. Entry No.");
                    if LSVJnlLine."Direct Debit Mandate ID" <> '' then
                        ToDirectDebitCollectionEntry.Validate("Mandate ID", LSVJnlLine."Direct Debit Mandate ID");
                    ToDirectDebitCollectionEntry.Validate("Transfer Amount", LSVJnlLine."Collection Amount");
                    ToDirectDebitCollectionEntry.Insert(true);
                until LSVJnlLine.Next() = 0;
        end;

        OnAfterCreateTempCollectionEntries(FromDirectDebitCollectionEntry, ToDirectDebitCollectionEntry);
    end;

    /// <summary>
    /// Integration event raised after creating temporary collection entries.
    /// Allows subscribers to modify or enhance the temporary entries after creation.
    /// </summary>
    /// <param name="FromDirectDebitCollectionEntry">Source entry record used as template.</param>
    /// <param name="ToDirectDebitCollectionEntry">Target temporary entry that was created.</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateTempCollectionEntries(var FromDirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var ToDirectDebitCollectionEntry: Record "Direct Debit Collection Entry")
    begin
    end;

    /// <summary>
    /// Integration event raised before creating temporary collection entries.
    /// Allows subscribers to provide custom logic for temporary entry creation.
    /// </summary>
    /// <param name="FromDirectDebitCollectionEntry">Source entry record used as template.</param>
    /// <param name="ToDirectDebitCollectionEntry">Target temporary entry to be created.</param>
    /// <param name="isHandled">Set to true if the subscriber handles the entry creation completely.</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateTempCollectionEntries(var FromDirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var ToDirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var isHandled: Boolean)
    begin
    end;
}


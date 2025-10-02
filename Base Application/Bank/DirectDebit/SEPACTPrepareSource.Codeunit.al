// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.DirectDebit;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Bank.Payment;

/// <summary>
/// Prepares general journal line data for SEPA credit transfer XML export by copying and organizing
/// eligible journal entries into a temporary structure for XMLPort processing.
/// </summary>
codeunit 1222 "SEPA CT-Prepare Source"
{
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.CopyFilters(Rec);
        CopyJnlLines(GenJnlLine, Rec);
    end;

    /// <summary>
    /// Copies eligible general journal lines to a temporary table for SEPA credit transfer processing.
    /// Processes journal lines and applies customization through integration events.
    /// </summary>
    /// <param name="FromGenJnlLine">Source general journal lines with applied filters.</param>
    /// <param name="TempGenJnlLine">Target temporary table to receive the processed journal lines.</param>
    local procedure CopyJnlLines(var FromGenJnlLine: Record "Gen. Journal Line"; var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    var
        GenJnlBatch: Record "Gen. Journal Batch";
    begin
        if FromGenJnlLine.FindSet() then begin
            GenJnlBatch.Get(FromGenJnlLine."Journal Template Name", FromGenJnlLine."Journal Batch Name");

            repeat
                TempGenJnlLine := FromGenJnlLine;
                OnCopyJnlLinesOnBeforeTempGenJnlLineInsert(FromGenJnlLine, TempGenJnlLine, GenJnlBatch);
                TempGenJnlLine.Insert();
            until FromGenJnlLine.Next() = 0
        end else
            CreateTempJnlLines(FromGenJnlLine, TempGenJnlLine);
    end;

    /// <summary>
    /// Creates temporary journal lines when no source lines are found.
    /// Allows customization through integration events for alternative data population strategies.
    /// </summary>
    /// <param name="FromGenJnlLine">Source journal line record used as template for temporary lines.</param>
    /// <param name="TempGenJnlLine">Target temporary table to populate with generated journal lines.</param>
    local procedure CreateTempJnlLines(var FromGenJnlLine: Record "Gen. Journal Line"; var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    var
        PaymentHistory: Record "Payment History";
        PaymentHistoryLine: Record "Payment History Line";
        AppliedDocNoList: Text;
        DescriptionLen: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateTempJnlLines(FromGenJnlLine, TempGenJnlLine, IsHandled);
        if IsHandled then
            exit;

        PaymentHistory.Get(FromGenJnlLine.GetFilter("Bal. Account No."), FromGenJnlLine.GetFilter("Document No."));
        PaymentHistoryLine.SetRange("Our Bank", PaymentHistory."Our Bank");
        PaymentHistoryLine.SetRange("Run No.", PaymentHistory."Run No.");
        if PaymentHistoryLine.FindSet() then
            repeat
                TempGenJnlLine.Init();
                TempGenJnlLine."Journal Template Name" := '';
                TempGenJnlLine."Journal Batch Name" := '';
                TempGenJnlLine."Bal. Account No." := PaymentHistory."Our Bank";
                TempGenJnlLine."Document No." := PaymentHistory."Run No.";
                TempGenJnlLine."Line No." := PaymentHistoryLine."Line No.";
                TempGenJnlLine."Account No." := PaymentHistoryLine."Account No.";
                case PaymentHistoryLine."Account Type" of
                    PaymentHistoryLine."Account Type"::Customer:
                        begin
                            TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::Customer;
                            TempGenJnlLine."Document Type" := TempGenJnlLine."Document Type"::Refund;
                        end;
                    PaymentHistoryLine."Account Type"::Employee:
                        begin
                            TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::Employee;
                            TempGenJnlLine."Document Type" := TempGenJnlLine."Document Type"::Payment;
                        end;
                    PaymentHistoryLine."Account Type"::Vendor:
                        begin
                            TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::Vendor;
                            TempGenJnlLine."Document Type" := TempGenJnlLine."Document Type"::Payment;
                        end;
                end;
                TempGenJnlLine.Amount := PaymentHistoryLine.Amount;
                TempGenJnlLine."Bal. Account Type" := TempGenJnlLine."Bal. Account Type"::"Bank Account";
                TempGenJnlLine."Currency Code" := PaymentHistoryLine."Currency Code";
                TempGenJnlLine."Posting Date" := PaymentHistoryLine.Date;
                TempGenJnlLine."Recipient Bank Account" := PaymentHistoryLine.Bank;

                TempGenJnlLine.Description := PaymentHistoryLine."Description 1";
                DescriptionLen := MaxStrLen(TempGenJnlLine.Description);
                AppliedDocNoList := PaymentHistoryLine.GetAppliedDocNoList(DescriptionLen);
                if AppliedDocNoList <> '' then begin
                    TempGenJnlLine.Description := CopyStr(AppliedDocNoList, 1, DescriptionLen);
                    if StrLen(AppliedDocNoList) > DescriptionLen then
                        TempGenJnlLine."Message to Recipient" :=
                          CopyStr(AppliedDocNoList, DescriptionLen + 1, DescriptionLen + MaxStrLen(TempGenJnlLine."Message to Recipient"));
                end;

                TempGenJnlLine.Insert();
            until PaymentHistoryLine.Next() = 0;

        OnAfterCreateTempJnlLines(FromGenJnlLine, TempGenJnlLine);
    end;

    /// <summary>
    /// Integration event raised after creating temporary journal lines.
    /// Allows subscribers to modify or enhance the temporary lines after standard processing.
    /// </summary>
    /// <param name="FromGenJnlLine">Source journal line record used as template.</param>
    /// <param name="TempGenJnlLine">Target temporary journal line that was created or modified.</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateTempJnlLines(var FromGenJnlLine: Record "Gen. Journal Line"; var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    begin
    end;

    /// <summary>
    /// Integration event raised before creating temporary journal lines.
    /// Allows subscribers to provide custom logic for temporary line creation.
    /// </summary>
    /// <param name="FromGenJnlLine">Source journal line record used as template.</param>
    /// <param name="TempGenJnlLine">Target temporary journal line to be created.</param>
    /// <param name="IsHandled">Set to true if the subscriber handles the line creation completely.</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateTempJnlLines(var FromGenJnlLine: Record "Gen. Journal Line"; var TempGenJnlLine: Record "Gen. Journal Line" temporary; var IsHandled: Boolean)
    begin
    end;

    /// <summary>
    /// Integration event raised before inserting temporary journal lines during the copy process.
    /// Allows subscribers to modify journal line data or apply custom transformations.
    /// </summary>
    /// <param name="FromGenJournalLine">Source journal line being processed.</param>
    /// <param name="TempGenJournalLine">Target temporary journal line to be inserted.</param>
    /// <param name="GenJournalBatch">Journal batch context for the operation.</param>
    [IntegrationEvent(false, false)]
    local procedure OnCopyJnlLinesOnBeforeTempGenJnlLineInsert(var FromGenJournalLine: Record "Gen. Journal Line"; var TempGenJournalLine: Record "Gen. Journal Line" temporary; GenJournalBatch: Record "Gen. Journal Batch")
    begin
    end;
}


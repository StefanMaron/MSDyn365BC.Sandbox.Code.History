﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.RoleCenters;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Foundation.Period;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Tracking;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Receivables;
using System.Environment;

codeunit 1311 "Activities Mgt."
{

    trigger OnRun()
    begin
        if IsCueDataStale() then
            RefreshActivitiesCueData();
    end;

    var
        DefaultWorkDate: Date;
        RefreshFrequencyErr: Label 'Refresh intervals of less than 10 minutes are not supported.';
        NoSubCategoryWithAdditionalReportDefinitionOfCashAccountsTok: Label 'There are no %1 with %2 specified for %3', Comment = '%1 Table Comment G/L Account Category, %2 field Additional Report Definition, %3 value: Cash Accounts';

    procedure OverdueSalesInvoiceAmount(CalledFromWebService: Boolean; UseCachedValue: Boolean) TotalAmount: Decimal
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ActivitiesCue: Record "Activities Cue";
        [SecurityFiltering(SecurityFilter::Filtered)]
        CustLedgEntryRemainAmt: Query "Cust. Ledg. Entry Remain. Amt.";
    begin
        if UseCachedValue then
            if ActivitiesCue.Get() then
                if not IsPassedCueData(ActivitiesCue) then
                    exit(ActivitiesCue."Overdue Sales Invoice Amount");

        CustLedgEntryRemainAmt.SetRange(Document_Type, CustLedgerEntry."Document Type"::Invoice);
        CustLedgEntryRemainAmt.SetRange(IsOpen, true);
        if CalledFromWebService then
            CustLedgEntryRemainAmt.SetFilter(Due_Date, '<%1', Today())
        else
            CustLedgEntryRemainAmt.SetFilter(Due_Date, '<%1', GetDefaultWorkDate());
        CustLedgEntryRemainAmt.Open();
        if CustLedgEntryRemainAmt.Read() then
            TotalAmount := CustLedgEntryRemainAmt.Sum_Remaining_Amt_LCY;
    end;

    procedure SetFilterOverdueSalesInvoice(var CustLedgerEntry: Record "Cust. Ledger Entry"; CalledFromWebService: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetFilterOverdueSalesInvoice(CustLedgerEntry, CalledFromWebService, IsHandled);
        if IsHandled then
            exit;

        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open, true);
        if CalledFromWebService then
            CustLedgerEntry.SetFilter("Due Date", '<%1', Today())
        else
            CustLedgerEntry.SetFilter("Due Date", '<%1', GetDefaultWorkDate());
    end;

    procedure DrillDownCalcOverdueSalesInvoiceAmount()
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        CustLedgerEntry: Record "Cust. Ledger Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDrillDownCalcOverdueSalesInvoiceAmount(CustLedgerEntry, IsHandled);
        if IsHandled then
            exit;

        SetFilterOverdueSalesInvoice(CustLedgerEntry, false);
        CustLedgerEntry.SetFilter("Remaining Amt. (LCY)", '<>0');
        CustLedgerEntry.SetCurrentKey("Remaining Amt. (LCY)");
        CustLedgerEntry.Ascending := false;

        Page.Run(Page::"Customer Ledger Entries", CustLedgerEntry);
    end;

    procedure OverduePurchaseInvoiceAmount(CalledFromWebService: Boolean; UseCachedValue: Boolean) TotalAmount: Decimal
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ActivitiesCue: Record "Activities Cue";
        [SecurityFiltering(SecurityFilter::Filtered)]
        VendLedgEntryRemainAmt: Query "Vend. Ledg. Entry Remain. Amt.";
    begin
        if UseCachedValue then
            if ActivitiesCue.Get() then
                if not IsPassedCueData(ActivitiesCue) then
                    exit(ActivitiesCue."Overdue Purch. Invoice Amount");

        VendLedgEntryRemainAmt.SetRange(Document_Type, VendorLedgerEntry."Document Type"::Invoice);
        VendLedgEntryRemainAmt.SetRange(IsOpen, true);
        if CalledFromWebService then
            VendLedgEntryRemainAmt.SetFilter(Due_Date, '<%1', Today())
        else
            VendLedgEntryRemainAmt.SetFilter(Due_Date, '<%1', GetDefaultWorkDate());
        VendLedgEntryRemainAmt.Open();
        if VendLedgEntryRemainAmt.Read() then
            TotalAmount := -VendLedgEntryRemainAmt.Sum_Remaining_Amt_LCY;
    end;

    procedure SetFilterOverduePurchaseInvoice(var VendorLedgerEntry: Record "Vendor Ledger Entry"; CalledFromWebService: Boolean)
    begin
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetRange(Open, true);
        if CalledFromWebService then
            VendorLedgerEntry.SetFilter("Due Date", '<%1', Today())
        else
            VendorLedgerEntry.SetFilter("Due Date", '<%1', GetDefaultWorkDate());

        OnAfterSetFilterOverduePurchaseInvoice(VendorLedgerEntry, CalledFromWebService);
    end;

    procedure DrillDownOverduePurchaseInvoiceAmount()
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDrillDownOverduePurchaseInvoiceAmount(VendorLedgerEntry, IsHandled);
        if IsHandled then
            exit;

        SetFilterOverduePurchaseInvoice(VendorLedgerEntry, false);
        VendorLedgerEntry.SetFilter("Remaining Amt. (LCY)", '<>0');
        VendorLedgerEntry.SetCurrentKey("Remaining Amt. (LCY)");
        VendorLedgerEntry.Ascending := true;

        Page.Run(Page::"Vendor Ledger Entries", VendorLedgerEntry);
    end;

    procedure CalcSalesThisMonthAmount(CalledFromWebService: Boolean) TotalAmount: Decimal
    begin
        exit(CalcSalesThisMonthAmount(CalledFromWebService, true));
    end;

    procedure CalcSalesThisMonthAmount(CalledFromWebService: Boolean; UseCachedValue: Boolean) TotalAmount: Decimal
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ActivitiesCue: Record "Activities Cue";
        [SecurityFiltering(SecurityFilter::Filtered)]
        CustLedgEntrySales: Query "Cust. Ledg. Entry Sales";
    begin
        if UseCachedValue then
            if ActivitiesCue.Get() then
                if not IsPassedCueData(ActivitiesCue) then
                    exit(ActivitiesCue."Sales This Month");

        CustLedgEntrySales.SetFilter(Document_Type, '%1|%2', CustLedgerEntry."Document Type"::Invoice, CustLedgerEntry."Document Type"::"Credit Memo");
        if CalledFromWebService then
            CustLedgEntrySales.SetRange(Posting_Date, CalcDate('<-CM>', Today()), Today())
        else
            CustLedgEntrySales.SetRange(Posting_Date, CalcDate('<-CM>', GetDefaultWorkDate()), GetDefaultWorkDate());
        CustLedgEntrySales.Open();
        if CustLedgEntrySales.Read() then
            TotalAmount := CustLedgEntrySales.Sum_Sales_LCY;
    end;

    [Scope('OnPrem')]
    procedure SetFilterForCalcSalesThisMonthAmount(var CustLedgerEntry: Record "Cust. Ledger Entry"; CalledFromWebService: Boolean)
    begin
        CustLedgerEntry.SetFilter("Document Type", '%1|%2',
          CustLedgerEntry."Document Type"::Invoice, CustLedgerEntry."Document Type"::"Credit Memo");
        if CalledFromWebService then
            CustLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', Today()), Today())
        else
            CustLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', GetDefaultWorkDate()), GetDefaultWorkDate());
    end;

    procedure DrillDownSalesThisMonth()
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetFilter("Document Type", '%1|%2',
          CustLedgerEntry."Document Type"::Invoice, CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', GetDefaultWorkDate()), GetDefaultWorkDate());
        Page.Run(Page::"Customer Ledger Entries", CustLedgerEntry);
    end;

    procedure CalcSalesYTD() TotalAmount: Decimal
    var
        AccountingPeriod: Record "Accounting Period";
        [SecurityFiltering(SecurityFilter::Filtered)]
        CustLedgEntrySales: Query "Cust. Ledg. Entry Sales";
    begin
        CustLedgEntrySales.SetRange(Posting_Date, AccountingPeriod.GetFiscalYearStartDate(GetDefaultWorkDate()), GetDefaultWorkDate());
        CustLedgEntrySales.Open();
        if CustLedgEntrySales.Read() then
            TotalAmount := CustLedgEntrySales.Sum_Sales_LCY;
    end;

    procedure CalcTop10CustomerSalesYTD() TotalAmount: Decimal
    var
        AccountingPeriod: Record "Accounting Period";
        Top10CustomerSales: Query "Top 10 Customer Sales";
    begin
        // Total Sales (LCY) by top 10 list of customers year-to-date.
        Top10CustomerSales.SetRange(Posting_Date, AccountingPeriod.GetFiscalYearStartDate(GetDefaultWorkDate()), GetDefaultWorkDate());
        Top10CustomerSales.Open();
        while Top10CustomerSales.Read() do
            TotalAmount += Top10CustomerSales.Sum_Sales_LCY;
    end;

    procedure CalcTop10CustomerSalesRatioYTD() CalculatedRatio: Decimal
    var
        TotalSales: Decimal;
    begin
        // Ratio of Sales by top 10 list of customers year-to-date.
        TotalSales := CalcSalesYTD();
        if TotalSales <> 0 then
            CalculatedRatio := CalcTop10CustomerSalesYTD() / TotalSales;
    end;

    procedure CalcAverageCollectionDays() AverageDays: Decimal
    begin
        exit(CalcAverageCollectionDays(true));
    end;

    procedure CalcAverageCollectionDays(UseCachedValue: Boolean) AverageDays: Decimal
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ActivitiesCue: Record "Activities Cue";
        SumCollectionDays: Integer;
        CountInvoices: Integer;
    begin
        if UseCachedValue then
            if ActivitiesCue.Get() then
                if not IsPassedCueData(ActivitiesCue) then
                    exit(ActivitiesCue."Average Collection Days");

        CustLedgerEntry.ReadIsolation(IsolationLevel::ReadUncommitted);
        CustLedgerEntry.SetLoadFields("Posting Date", "Closed at Date");
        GetPaidSalesInvoices(CustLedgerEntry);
        if CustLedgerEntry.FindSet() then begin
            repeat
                SumCollectionDays += (CustLedgerEntry."Closed at Date" - CustLedgerEntry."Posting Date");
                CountInvoices += 1;
            until CustLedgerEntry.Next() = 0;

            AverageDays := SumCollectionDays / CountInvoices;
        end
    end;

    procedure CalcNoOfReservedFromStockSalesOrders() Number: Integer
    var
    begin
        exit(CalcNoOfReservedFromStockSalesOrders(true));
    end;

    procedure CalcNoOfReservedFromStockSalesOrders(UseCachedValue: Boolean) Number: Integer
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReservationEntry: Record "Reservation Entry";
        ActivitiesCue: Record "Activities Cue";
        SalesReservFromItemLedger: Query "Sales Reserv. From Item Ledger";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcNoOfReservedFromStockSalesOrders(SalesHeader, Number, IsHandled);
        if IsHandled then
            exit(Number);

        if UseCachedValue then
            if ActivitiesCue.Get() then
                if not IsPassedCueData(ActivitiesCue) then
                    exit(ActivitiesCue."S. Ord. - Reserved From Stock");

        Number := 0;

        if not ReservationEntry.ReadPermission() then
            exit;

        ReservationEntry.ReadIsolation(IsolationLevel::ReadUncommitted);
        ReservationEntry.SetRange(Positive, true);
        ReservationEntry.SetRange("Source Type", Database::"Item Ledger Entry");
        ReservationEntry.SetRange("Reservation Status", ReservationEntry."Reservation Status"::Reservation);
        if ReservationEntry.IsEmpty() then
            exit;

        SalesReservFromItemLedger.Open();
        while SalesReservFromItemLedger.Read() do
            if SalesReservFromItemLedger.Reserved_Quantity__Base_ <> 0 then begin
                SalesHeader.SetLoadFields("Document Type", "No.");
                if SalesHeader.Get(SalesHeader."Document Type"::Order, SalesReservFromItemLedger.SalesHeaderNo) then begin
                    SalesLine.SetLoadFields("Document Type", "Document No.", Type, "Outstanding Qty. (Base)");
                    SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.CalcSums("Outstanding Qty. (Base)");
                    if SalesReservFromItemLedger.Reserved_Quantity__Base_ = SalesLine."Outstanding Qty. (Base)" then
                        Number += 1;
                end;
            end;
    end;

    procedure DrillDownNoOfReservedFromStockSalesOrders()
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        SalesHeader: Record "Sales Header";
    begin
        OnBeforeDrillDownNoOfReservedFromStockSalesOrders(SalesHeader);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetLoadFields("Document Type", "No.");
        if SalesHeader.FindSet() then
            repeat
                if SalesHeader.GetQtyReservedFromStockState() = Enum::"Reservation From Stock"::Full then
                    SalesHeader.Mark(true);
            until SalesHeader.Next() = 0;
        SalesHeader.MarkedOnly(true);
        Page.Run(Page::"Sales Order List", SalesHeader);
    end;

    local procedure GetPaidSalesInvoices(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open, false);
        CustLedgerEntry.SetRange("Posting Date", CalcDate('<CM-3M>', GetDefaultWorkDate()), GetDefaultWorkDate());
        CustLedgerEntry.SetRange("Closed at Date", CalcDate('<CM-3M>', GetDefaultWorkDate()), GetDefaultWorkDate());
    end;

    procedure CalcCashAccountsBalances() CashAccountBalance: Decimal
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        GLAccount: Record "G/L Account";
        [SecurityFiltering(SecurityFilter::Filtered)]
        GLAccountCategory: Record "G/L Account Category";
        [SecurityFiltering(SecurityFilter::Filtered)]
        GLEntry: Record "G/L Entry";
    begin
        GLAccount.SetRange("Account Category", GLAccount."Account Category"::Assets);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetFilter("Account Subcategory Entry No.", CreateFilterForGLAccSubCategoryEntries(GLAccountCategory."Additional Report Definition"::"Cash Accounts"));
        GLEntry.SetFilter("G/L Account No.", CreateFilterForGLAccounts(GLAccount));
        GLEntry.CalcSums(Amount);
        CashAccountBalance := GLEntry.Amount;
    end;

    procedure DrillDownCalcCashAccountsBalances()
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        GLAccount: Record "G/L Account";
        [SecurityFiltering(SecurityFilter::Filtered)]
        GLAccountCategory: Record "G/L Account Category";
    begin
        GLAccount.SetRange("Account Category", GLAccount."Account Category"::Assets);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        TestifSubCategoryIsSpecifield();
        GLAccount.SetFilter("Account Subcategory Entry No.", CreateFilterForGLAccSubCategoryEntries(GLAccountCategory."Additional Report Definition"::"Cash Accounts"));
        Page.Run(Page::"Chart of Accounts", GLAccount);
    end;

    local procedure SetGLAccountsFilterForARAccounts(var GLAccount: Record "G/L Account"): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GLAccountCategory: Record "G/L Account Category";
    begin
        if not GeneralLedgerSetup.Get() then
            exit(false);
        GLAccountCategory.SetLoadFields("Entry No.");
        if not GLAccountCategory.Get(GeneralLedgerSetup."Acc. Receivables Category") then
            exit(false);

        GLAccount.SetRange("Account Category", GLAccount."Account Category"::Assets);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Account Subcategory Entry No.", GLAccountCategory."Entry No.");
        exit(true);
    end;

    internal procedure CalcARAccountsBalances(): Decimal
    var
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
    begin
        if not SetGLAccountsFilterForARAccounts(GLAccount) then
            exit(0);

        GLEntry.SetFilter("G/L Account No.", CreateFilterForGLAccounts(GLAccount));
        GLEntry.SetRange("Business Unit Code", '');
        GLEntry.CalcSums(Amount);
        exit(GLEntry.Amount);
    end;

    internal procedure DrillDownCalcARAccountsBalances()
    var
        GLAccount: Record "G/L Account";
    begin
        if not SetGLAccountsFilterForARAccounts(GLAccount) then
            Page.Run(Page::"General Ledger Setup");
        GLAccount.SetFilter("Business Unit Filter", ' = %1', '');
        Page.Run(Page::"Chart of Accounts", GLAccount);
    end;

    local procedure TestifSubCategoryIsSpecifield();
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        GLAccountCategory.SetRange("Additional Report Definition", GLAccountCategory."Additional Report Definition"::"Cash Accounts");
        if GLAccountCategory.IsEmpty() then
            Message(NoSubCategoryWithAdditionalReportDefinitionOfCashAccountsTok,
              GLAccountCategory.TableCaption(), GLAccountCategory.FieldCaption("Additional Report Definition"),
              GLAccountCategory."Additional Report Definition"::"Cash Accounts");
    end;

    local procedure RefreshActivitiesCueData()
    var
        ActivitiesCue: Record "Activities Cue";
    begin
        ActivitiesCue.LockTable();

        ActivitiesCue.Get();

        if not IsPassedCueData(ActivitiesCue) then
            exit;

        ActivitiesCue.SetFilter("Due Date Filter", '>=%1', GetDefaultWorkDate());
        ActivitiesCue.SetFilter("Overdue Date Filter", '<%1', GetDefaultWorkDate());
        ActivitiesCue.SetFilter("Due Next Week Filter", '%1..%2', CalcDate('<1D>', GetDefaultWorkDate()), CalcDate('<1W>', GetDefaultWorkDate()));

        if ActivitiesCue.FieldActive("Overdue Sales Invoice Amount") then
            ActivitiesCue."Overdue Sales Invoice Amount" := OverdueSalesInvoiceAmount(false, false);

        if ActivitiesCue.FieldActive("Overdue Purch. Invoice Amount") then
            ActivitiesCue."Overdue Purch. Invoice Amount" := OverduePurchaseInvoiceAmount(false, false);

        if ActivitiesCue.FieldActive("Sales This Month") then
            ActivitiesCue."Sales This Month" := CalcSalesThisMonthAmount(false, false);

        if ActivitiesCue.FieldActive("Average Collection Days") then
            ActivitiesCue."Average Collection Days" := CalcAverageCollectionDays(false);

        if ActivitiesCue.FieldActive("S. Ord. - Reserved From Stock") then
            ActivitiesCue."S. Ord. - Reserved From Stock" := CalcNoOfReservedFromStockSalesOrders(false);

        ActivitiesCue."Last Date/Time Modified" := CurrentDateTime();
        OnRefreshActivitiesCueDataOnBeforeModify(ActivitiesCue);
        ActivitiesCue.Modify();
        Commit();
    end;

    [Scope('OnPrem')]
    procedure IsCueDataStale(): Boolean
    var
        ActivitiesCue: Record "Activities Cue";
    begin
        if not ActivitiesCue.Get() then
            exit(false);

        exit(IsPassedCueData(ActivitiesCue));
    end;

    local procedure IsPassedCueData(ActivitiesCue: Record "Activities Cue"): Boolean
    begin
        if ActivitiesCue."Last Date/Time Modified" = 0DT then
            exit(true);

        exit(CurrentDateTime() - ActivitiesCue."Last Date/Time Modified" >= GetActivitiesCueRefreshInterval())
    end;

    local procedure GetDefaultWorkDate(): Date
    var
        LogInManagement: Codeunit LogInManagement;
    begin
        if DefaultWorkDate = 0D then
            DefaultWorkDate := LogInManagement.GetDefaultWorkDate();
        exit(DefaultWorkDate);
    end;

    local procedure GetActivitiesCueRefreshInterval() Interval: Duration
    var
        MinInterval: Duration;
    begin
        MinInterval := 10 * 60 * 1000; // 10 minutes
        Interval := 60 * 60 * 1000; // 1 hr
        OnGetRefreshInterval(Interval);
        if Interval < MinInterval then
            Error(RefreshFrequencyErr);
    end;

    local procedure CreateFilterForGLAccSubCategoryEntries(AddRepDef: Option): Text
    var
        GLAccountCategory: Record "G/L Account Category";
        FilterOperand: Char;
        FilterTxt: Text;
    begin
        FilterOperand := '|';
        GLAccountCategory.SetLoadFields("Entry No.");
        GLAccountCategory.SetRange("Additional Report Definition", AddRepDef);
        if GLAccountCategory.FindSet() then
            repeat
                if FilterTxt = '' then
                    FilterTxt := Format(GLAccountCategory."Entry No.") + FilterOperand
                else
                    FilterTxt := FilterTxt + Format(GLAccountCategory."Entry No.") + FilterOperand;
            until GLAccountCategory.Next() = 0;
        // Remove the last |
        exit(DelChr(FilterTxt, '>', FilterOperand));
    end;

    local procedure CreateFilterForGLAccounts(var GLAccount: Record "G/L Account"): Text
    var
        FilterOperand: Char;
        FilterTxt: Text;
    begin
        FilterOperand := '|';
        GLAccount.SetLoadFields("No.");
        if GLAccount.FindSet() then
            repeat
                if FilterTxt = '' then
                    FilterTxt := Format(GLAccount."No.") + FilterOperand
                else
                    FilterTxt := FilterTxt + Format(GLAccount."No.") + FilterOperand;
            until GLAccount.Next() = 0;
        // Remove the last |
        exit(DelChr(FilterTxt, '>', FilterOperand));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFilterOverduePurchaseInvoice(var VendorLedgerEntry: Record "Vendor Ledger Entry"; CalledFromWebService: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDrillDownCalcOverdueSalesInvoiceAmount(var CustLedgerEntry: Record "Cust. Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDrillDownOverduePurchaseInvoiceAmount(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetFilterOverdueSalesInvoice(var CustLedgerEntry: Record "Cust. Ledger Entry"; CalledFromWebService: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetRefreshInterval(var Interval: Duration)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRefreshActivitiesCueDataOnBeforeModify(var ActivitiesCue: Record "Activities Cue")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDrillDownNoOfReservedFromStockSalesOrders(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcNoOfReservedFromStockSalesOrders(var SalesHeader: Record "Sales Header"; var Number: Integer; var IsHandled: Boolean)
    begin
    end;
}


﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;
using System.IO;

report 12173 "Issued Cust Bills Floppy"
{
    Caption = 'Issued Cust Bills Floppy';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Issued Customer Bill Header"; "Issued Customer Bill Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            dataitem("Issued Customer Bill Line"; "Issued Customer Bill Line")
            {
                DataItemLink = "Customer Bill No." = field("No.");
                DataItemTableView = sorting("Customer No.", "Due Date", "Customer Bank Acc. No.", "Cumulative Bank Receipts") ORDER(Ascending) where("Recalled by" = filter(''));

                trigger OnAfterGetRecord()
                begin
                    if OldCustomer = '' then begin
                        OldCustomer := "Customer No.";
                        OldDueDate := "Due Date";
                        OldBankAcc := "Customer Bank Acc. No.";
                    end;

                    if "Cumulative Bank Receipts" then
                        if ("Customer No." <> OldCustomer) or
                           ("Due Date" <> OldDueDate) or
                           ("Customer Bank Acc. No." <> OldBankAcc)
                        then begin
                            OldCustomer := "Customer No.";
                            OldDueDate := "Due Date";
                            OldBankAcc := "Customer Bank Acc. No.";

                            if CumAmount <> 0 then
                                WriteRecord(OldIssuedCustomerBillLine);

                            CumAmount := Amount;
                        end else begin
                            CumAmount := CumAmount + Amount;
                            OldIssuedCustomerBillLine := "Issued Customer Bill Line";
                        end
                    else begin
                        if CumAmount <> 0 then begin
                            WriteRecord(OldIssuedCustomerBillLine);
                            CumAmount := 0;
                        end;
                        WriteRecord("Issued Customer Bill Line");
                    end;
                    OldIssuedCustomerBillLine := "Issued Customer Bill Line";
                end;

                trigger OnPostDataItem()
                begin
                    if CumAmount <> 0 then
                        WriteRecord("Issued Customer Bill Line");

                    WriteFooter();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CountRecord := CountRecord + 1;

                if CountRecord > 1 then
                    Error(Text1130020, TableCaption);

                BRProgr := 0;
                TotAmount := 0;
                OldCustomer := '';
                OldDueDate := 0D;
                WriteHeader();
            end;

            trigger OnPostDataItem()
            begin
                Window.Close();
            end;

            trigger OnPreDataItem()
            begin
                if GetFilter("No.") = '' then
                    Error(Text1130020, TableCaption);

                Window.Open(Text1130025);
                CountRecord := 0;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        if FileName = '' then
            FileName := 'C:\EFFETTI.TXT';

        CurrCode := 'E';
    end;

    trigger OnPostReport()
    begin
        OutFile.Close();

        if ServerFileName <> '' then begin
            RBMgt.CopyServerFile(FileName, ServerFileName, true);
            exit;
        end;

        if not RBMgt.DownloadHandler(FileName, '', 'C:', '', ToFile) then
            exit;

        Message(Text1130023, ToFile);
    end;

    trigger OnPreReport()
    begin
        if Exists(FileName) then
            if not Confirm(Text1130021, false, FileName) then
                Error(Text1130022, FileName);

        CompanyInfo.Get();
        CompanyInfo.TestField("SIA Code");
        CompanyInfo.TestField("Signature on Bill");

        FillChar := ' ';
        Dummy := '';
        Dummy := PadStr(Dummy, 120, FillChar);

        Clear(OutFile);
        OutFile.TextMode := true;
        OutFile.WriteMode := true;
        FileName := RBMgt.ServerTempFileName('');
        ToFile := 'EFFETTI.TXT';
        OutFile.Create(FileName);
    end;

    var
        CompanyInfo: Record "Company Information";
        BankAcc: Record "Bank Account";
        Cust: Record Customer;
        CustBankAcc: Record "Customer Bank Account";
        OldIssuedCustomerBillLine: Record "Issued Customer Bill Line";
        RBMgt: Codeunit "File Management";
        LocalAppMgt: Codeunit LocalApplicationManagement;
        Window: Dialog;
        OutFile: File;
        FileName: Text[1024];
        OutText: Text[120];
        Dummy: Text[120];
        ABI: Integer;
        CAB: Integer;
        OldCustomer: Code[20];
        OldBankAcc: Code[20];
        BRProgr: Integer;
        CountRecord: Integer;
        LineAmount: Decimal;
        CumAmount: Decimal;
        TotAmount: Decimal;
        Sign: Text[1];
        FillChar: Text[1];
        OldDueDate: Date;
        Text1130020: Label 'This batch requires you to specify one %1 at a time.';
        Text1130021: Label 'File %1 already exists.\Do you want to replace the existing file?';
        Text1130022: Label 'File %1 already exists.';
        Text1130023: Label 'File %1 has been created successfully.';
        Text1130025: Label 'Please wait while the operation is being completed.';
        Text002: Label 'Sundry invoices';
        CustABI: Integer;
        CustCAB: Integer;
        CustomerTemp: Text[20];
        BRAmount: Decimal;
        CurrCode: Text[10];
        ToFile: Text[1024];
        ServerFileName: Text;

    [Scope('OnPrem')]
    procedure WriteHeader()
    begin
        ABI := 0;
        CAB := 0;

        if BankAcc.Get("Issued Customer Bill Header"."Bank Account No.") then begin
            BankAcc.TestField(ABI);
            BankAcc.TestField(CAB);
            Evaluate(ABI, BankAcc.ABI);
            Evaluate(CAB, BankAcc.CAB);
        end;
        OutText := ' IB' +
          Format(CompanyInfo."SIA Code", 5) +
          ConvertStr(Format(ABI, 5), ' ', '0') +
          Format(WorkDate(), 6, 5) +
          Format("Issued Customer Bill Header"."No.", 20) +
          CopyStr(Dummy, 40, 74) +
          CurrCode;

        OutText := PadStr(OutText, 120, ' ');
        OutFile.Write(OutText);
    end;

    [Scope('OnPrem')]
    procedure WriteFooter()
    begin
        OutText := '';
        ABI := 0;
        OutText := ' EF';
        BRAmount := TotAmount;
        if BankAcc.Get("Issued Customer Bill Header"."Bank Account No.") then
            Evaluate(ABI, BankAcc.ABI);

        OutText := OutText +
          Format(CompanyInfo."SIA Code", 5) +
          ConvertStr(Format(ABI, 5), ' ', '0') +
          Format(WorkDate(), 6, 5) +
          Format("Issued Customer Bill Header"."No.", 20) +
          CopyStr(Dummy, 40, 6) +
          ConvertStr(Format(BRProgr, 7), ' ', '0') +
          ConvertStr(Format(Abs(BRAmount), 15, 1), ' ', '0') +
          ConvertStr(Format(0, 15, 1), ' ', '0') +
          ConvertStr(Format(BRProgr * 7 + 2, 7), ' ', '0') +
          CopyStr(Dummy, 90, 24) +
          CurrCode;

        OutText := PadStr(OutText, 120, FillChar);
        OutFile.Write(OutText);
    end;

    [Scope('OnPrem')]
    procedure RECORD14(IssuedCustomerBillLine: Record "Issued Customer Bill Line")
    var
        IsHandled: Boolean;
    begin
        if IssuedCustomerBillLine."Cumulative Bank Receipts" then
            LineAmount := Round(CumAmount, 0.01) * 100
        else
            LineAmount := Round(IssuedCustomerBillLine.Amount, 0.01) * 100;

        TotAmount := TotAmount + LineAmount;
        Sign := '-';

        OutText := ' 14' +
          ConvertStr(Format(BRProgr, 7), ' ', '0') +
          CopyStr(Dummy, 11, 12) +
          Format(IssuedCustomerBillLine."Due Date", 6, 5) +
          '30000' +
          ConvertStr(Format(Abs(LineAmount), 13, 1), ' ', '0') +
          Sign +
          ConvertStr(Format(ABI, 5), ' ', '0') +
          ConvertStr(Format(CAB, 5), ' ', '0');

        IsHandled := false;
        OnRECORD14OnAfterAssignOutText(IssuedCustomerBillLine, OutText, IsHandled);
        if IsHandled then
            exit;

        if CustBankAcc.Get(IssuedCustomerBillLine."Customer No.", IssuedCustomerBillLine."Customer Bank Acc. No.") then begin
            CustBankAcc.TestField(ABI);
            CustBankAcc.TestField(CAB);
            Evaluate(CustABI, CustBankAcc.ABI);
            Evaluate(CustCAB, CustBankAcc.CAB);
            OutText := OutText + Format(BankAcc."Bank Account No.", 12) +
              ConvertStr(Format(CustABI, 5), ' ', '0') +
              ConvertStr(Format(CustCAB, 5), ' ', '0') +
              CopyStr(Dummy, 80, 12);
        end else
            OutText := OutText + CopyStr(Dummy, 58, 34);

        CustomerTemp := IssuedCustomerBillLine."Customer No.";
        OutText := OutText +
          Format(CompanyInfo."SIA Code", 5) + '4' + Format(CustomerTemp, 16) +
          CopyStr(Dummy, 114, 6) + CurrCode;

        OutText := PadStr(OutText, 120, FillChar);
    end;

    [Scope('OnPrem')]
    procedure RECORD20(IssuedCustomerBillLine: Record "Issued Customer Bill Line")
    begin
        OutText :=
            ' 20' +
            ConvertStr(Format(BRProgr, 7), ' ', '0') +
            Format(CompanyInfo.Name, 24) +
            Format(CompanyInfo.Address, 24) +
            Format(Format(CompanyInfo."Post Code"), 24) +
            Format(CompanyInfo.City, 24);

        OutText := PadStr(OutText, 120, FillChar);

        OnRECORD20OnAfterAssignOutText(IssuedCustomerBillLine, OutText);
    end;

    [Scope('OnPrem')]
    procedure RECORD30(IssuedCustomerBillLine: Record "Issued Customer Bill Line")
    var
        IsHandled: Boolean;
    begin
        OutText := ' 30' + ConvertStr(Format(BRProgr, 7), ' ', '0');

        IsHandled := false;
        OnRECORD30OnAfterAssignOutText(IssuedCustomerBillLine, OutText, IsHandled);
        if IsHandled then
            exit;

        if Cust.Get(IssuedCustomerBillLine."Customer No.") then
            OutText := OutText + Format(Cust.Name, 30) + Format(Cust."Name 2", 30);

        if Cust."Fiscal Code" <> '' then
            OutText := OutText + PadStr(Cust."Fiscal Code", 16)
        else
            OutText := OutText + PadStr(Cust."VAT Registration No.", 16);

        OutText := PadStr(OutText, 120, FillChar);
    end;

    [Scope('OnPrem')]
    procedure RECORD40(IssuedCustomerBillLine: Record "Issued Customer Bill Line")
    var
        IsHandled: Boolean;
    begin
        OutText := ' 40' + ConvertStr(Format(BRProgr, 7), ' ', '0');

        IsHandled := false;
        OnRECORD40OnAfterAssignOutText(IssuedCustomerBillLine, OutText, IsHandled);
        if IsHandled then
            exit;

        if Cust.Get(IssuedCustomerBillLine."Customer No.") then begin
            if Cust.Address = '' then
                OutText := OutText + CopyStr(Dummy, 11, 30)
            else
                OutText := OutText + Format(Cust.Address, 30);
            OutText := OutText +
              Format(Cust."Post Code", 5) +
              Format(Cust.City, 23) + Format(Cust.County, 2);
        end;

        if CustBankAcc.Get(IssuedCustomerBillLine."Customer No.", IssuedCustomerBillLine."Customer Bank Acc. No.") then
            if (CustBankAcc.ABI <> '') and (CustBankAcc.CAB <> '') then begin
                Evaluate(CustABI, CustBankAcc.ABI);
                Evaluate(CustCAB, CustBankAcc.CAB);
                OutText := OutText + ConvertStr(Format(CustABI, 5), ' ', '0') + ' ' +
                  ConvertStr(Format(CustCAB, 5), ' ', '0')
            end else
                OutText := OutText + Format(CustBankAcc.Name + ' ' + CustBankAcc.City, 50);
        OutText := PadStr(OutText, 120, FillChar);
    end;

    [Scope('OnPrem')]
    procedure RECORD50(IssuedCustomerBillLine: Record "Issued Customer Bill Line")
    var
        IsHandled: Boolean;
    begin
        OutText := ' 50' + ConvertStr(Format(BRProgr, 7), ' ', '0');
        IsHandled := false;
        OnRECORD50OnAfterAssignOutText(IssuedCustomerBillLine, OutText, IsHandled);
        if IsHandled then
            exit;

        if IssuedCustomerBillLine."Cumulative Bank Receipts" then
            OutText := OutText + Format(Text002, 80)
        else
            OutText := OutText + Format(IssuedCustomerBillLine."Document No.", 40) + Format(IssuedCustomerBillLine."Document Date", 40, 5);
        OutText := OutText + CopyStr(Dummy, 91, 10);
        if CompanyInfo."Fiscal Code" <> '' then
            OutText := OutText + PadStr(CompanyInfo."Fiscal Code", 16)
        else
            OutText := OutText + PadStr(CompanyInfo."VAT Registration No.", 16);
        OutText := PadStr(OutText, 120, FillChar);
    end;

    [Scope('OnPrem')]
    procedure RECORD51(IssuedCustomerBillLine: Record "Issued Customer Bill Line")
    begin
        OutText := ' 51' + ConvertStr(Format(BRProgr, 7), ' ', '0');
        OutText := OutText + LocalAppMgt.ConvertToNumeric(IssuedCustomerBillLine."Final Cust. Bill No.", 10);

        OutText := OutText +
          Format(CompanyInfo."Signature on Bill", 20) +
          Format(CompanyInfo."Authority County", 15) +
          Format(Format(CompanyInfo."Autoriz. No."), 10) +
          Format(CompanyInfo."Autoriz. Date", 6, 5);

        OutText := PadStr(OutText, 120, FillChar);

        OnRECORD51OnAfterAssignOutText(IssuedCustomerBillLine, OutText);
    end;

    [Scope('OnPrem')]
    procedure RECORD70(IssuedCustomerBillLine: Record "Issued Customer Bill Line")
    begin
        OutText := ' 70' + ConvertStr(Format(BRProgr, 7), ' ', '0');

        OutText := PadStr(OutText, 120, FillChar);

        OnRECORD70OnAfterAssignOutText(IssuedCustomerBillLine, OutText);
    end;

    [Scope('OnPrem')]
    procedure WriteRecord(Lines: Record "Issued Customer Bill Line")
    begin
        BRProgr := BRProgr + 1;

        RECORD14(Lines);
        OutFile.Write(OutText);

        RECORD20(Lines);
        OutFile.Write(OutText);

        RECORD30(Lines);
        OutFile.Write(OutText);

        RECORD40(Lines);
        OutFile.Write(OutText);

        RECORD50(Lines);
        OutFile.Write(OutText);

        RECORD51(Lines);
        OutFile.Write(OutText);

        RECORD70(Lines);
        OutFile.Write(OutText);
    end;

    [Scope('OnPrem')]
    procedure InitializeRequest(SrvFileName: Text)
    begin
        ServerFileName := SrvFileName;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRECORD50OnAfterAssignOutText(IssuedCustomerBillLine: Record "Issued Customer Bill Line"; var OutText: Text[120]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRECORD14OnAfterAssignOutText(IssuedCustomerBillLine: Record "Issued Customer Bill Line"; var OutText: Text[120]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRECORD20OnAfterAssignOutText(IssuedCustomerBillLine: Record "Issued Customer Bill Line"; var OutText: Text[120])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRECORD30OnAfterAssignOutText(IssuedCustomerBillLine: Record "Issued Customer Bill Line"; var OutText: Text[120]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRECORD40OnAfterAssignOutText(IssuedCustomerBillLine: Record "Issued Customer Bill Line"; var OutText: Text[120]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRECORD51OnAfterAssignOutText(IssuedCustomerBillLine: Record "Issued Customer Bill Line"; var OutText: Text[120])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRECORD70OnAfterAssignOutText(IssuedCustomerBillLine: Record "Issued Customer Bill Line"; var OutText: Text[120])
    begin
    end;
}


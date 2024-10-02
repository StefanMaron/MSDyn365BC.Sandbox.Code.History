﻿namespace Microsoft.Finance.GeneralLedger.Reports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Reporting;
using System.Utilities;

report 6 "Trial Balance"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Finance/GeneralLedger/Reports/TrialBalance.rdlc';
    AdditionalSearchTerms = 'year closing,close accounting period,close fiscal year';
    ApplicationArea = Basic, Suite;
    Caption = 'Trial Balance';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Account Type", "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter";
            column(STRSUBSTNO_Text000_PeriodText_; StrSubstNo(Text000, PeriodText))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(PeriodText; PeriodText)
            {
            }
            column(TotalCredit; TotalCredit)
            {
            }
            column(TotalDebit; TotalDebit)
            {
            }
            column(RoundingText; RoundingText)
            {
            }
            column(Rounding; Rounding)
            {
            }
            column(G_L_Account__TABLECAPTION__________GLFilter; TableCaption + ': ' + GLFilter)
            {
            }
            column(GLFilter; GLFilter)
            {
            }
            column(SimulationEntries; SimulationEntriesLbl)
            {
            }
            column(G_L_Account_No_; "No.")
            {
            }
            column(Trial_BalanceCaption; Trial_BalanceCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Net_ChangeCaption; Net_ChangeCaptionLbl)
            {
            }
            column(BalanceCaption; BalanceCaptionLbl)
            {
            }
            column(G_L_Account___No__Caption; FieldCaption("No."))
            {
            }
            column(PADSTR_____G_L_Account__Indentation___2___G_L_Account__NameCaption; PADSTR_____G_L_Account__Indentation___2___G_L_Account__NameCaptionLbl)
            {
            }
            column(G_L_Account___Net_Change_Caption; G_L_Account___Net_Change_CaptionLbl)
            {
            }
            column(G_L_Account___Net_Change__Control22Caption; G_L_Account___Net_Change__Control22CaptionLbl)
            {
            }
            column(G_L_Account___Balance_at_Date_Caption; G_L_Account___Balance_at_Date_CaptionLbl)
            {
            }
            column(G_L_Account___Balance_at_Date__Control24Caption; G_L_Account___Balance_at_Date__Control24CaptionLbl)
            {
            }
            column(PageGroupNo; PageGroupNo)
            {
            }
            column(TotalofPostedTransCaption; TotalofPostedTransCaptionLbl)
            {
            }
            column(AccountType_GLAcc; "G/L Account"."Account Type")
            {
            }
            column(UseAmtsInAddCurr; UseAmtsInAddCurr)
            {
            }
            column(AllAmountsAreIn; AllAmountsAreInLbl)
            {
            }
            column(GLSetupAddRepCurrency; GLSetup."Additional Reporting Currency")
            {
            }
            column(GlSetupLCYCode; GLSetup."LCY Code")
            {
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(G_L_Account___No__; "G/L Account"."No.")
                {
                }
                column(PADSTR_____G_L_Account__Indentation___2___G_L_Account__Name; PadStr('', "G/L Account".Indentation * 2) + "G/L Account".Name)
                {
                }
                column(G_L_Account___Net_Change_; NetChange)
                {
                }
                column(G_L_Account___Net_Change__Control22; -NetChange)
                {
                    AutoFormatType = 1;
                }
                column(G_L_Account___Balance_at_Date_; BalanceAtDate)
                {
                }
                column(G_L_Account___Balance_at_Date__Control24; -BalanceAtDate)
                {
                    AutoFormatType = 1;
                }
                column(G_L_Account___Account_Type_; Format("G/L Account"."Account Type", 0, 2))
                {
                }
                column(No__of_Blank_Lines; "G/L Account"."No. of Blank Lines")
                {
                }
                dataitem(BlankLineRepeater; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(BlankLineNo; BlankLineNo)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if BlankLineNo = 0 then
                            CurrReport.Break();

                        BlankLineNo -= 1;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    BlankLineNo := "G/L Account"."No. of Blank Lines" + 1;
                end;
            }

            trigger OnAfterGetRecord()
            var
                DebitAmount: Decimal;
                CreditAmount: Decimal;
            begin
                if UseAmtsInAddCurr then begin
                    CalcFields(
                      "Additional-Currency Net Change",
                      "Add.-Currency Balance at Date",
                      "Add.-Currency Debit Amount",
                      "Add.-Currency Credit Amount");
                    NetChange := "Additional-Currency Net Change";
                    BalanceAtDate := "Add.-Currency Balance at Date";
                    DebitAmount := "Add.-Currency Debit Amount";
                    CreditAmount := "Add.-Currency Credit Amount";
                end else begin
                    CalcFields("Net Change", "Balance at Date", "Debit Amount", "Credit Amount");
                    NetChange := "Net Change";
                    BalanceAtDate := "Balance at Date";
                    DebitAmount := "Debit Amount";
                    CreditAmount := "Credit Amount";
                end;
                NetChange := ReportMgmnt.RoundAmount(NetChange, Rounding);
                BalanceAtDate := ReportMgmnt.RoundAmount(BalanceAtDate, Rounding);
                DebitAmount := ReportMgmnt.RoundAmount(DebitAmount, Rounding);
                CreditAmount := ReportMgmnt.RoundAmount(CreditAmount, Rounding);
                AccountName := '';
                if IndentAccountName then
                    AccountName := PadStr('', "G/L Account".Indentation * 2) + "G/L Account".Name
                else
                    AccountName := "G/L Account".Name;

                if "G/L Account"."Account Type" = "G/L Account"."Account Type"::Posting then begin
                    TotalDebit := TotalDebit + DebitAmount;
                    TotalCredit := TotalCredit + CreditAmount;
                end;

                if ChangeGroupNo then begin
                    PageGroupNo += 1;
                    ChangeGroupNo := false;
                end;

                ChangeGroupNo := "New Page";
            end;

            trigger OnPreDataItem()
            begin
                GLSetup.Get();

                if not UseAmtsInAddCurr then
                    GLSetup.TestField("LCY Code");

                if Rounding <> Rounding::" " then
                    RoundingText := ReportMgmnt.RoundDescription(Rounding);

                PageGroupNo := 0;
                ChangeGroupNo := false;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(AmountsInWhole; Rounding)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Amounts in whole';
                        ToolTip = 'Specifies if the amounts in the report are shown in whole 1000s.';
                    }
                    field(IndentAccountName; IndentAccountName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Indent Account Name';
                        ToolTip = 'Specifies that you want to indent the report.';
                    }
                    field(UseAmtsInAddCurr; UseAmtsInAddCurr)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Amounts in Add. Reporting Currency';
                        MultiLine = true;
                        ToolTip = 'Specifies if you want report amounts to be shown in the additional reporting currency.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        "G/L Account".SecurityFiltering(SecurityFilter::Filtered);
        GLFilter := "G/L Account".GetFilters();
        PeriodText := "G/L Account".GetFilter("Date Filter");
    end;

    var
#pragma warning disable AA0074
#pragma warning disable AA0470
        Text000: Label 'Period: %1';
#pragma warning restore AA0470
#pragma warning restore AA0074
        GLSetup: Record "General Ledger Setup";
        ReportMgmnt: Codeunit "Report Management APAC";
        Trial_BalanceCaptionLbl: Label 'Trial Balance';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Net_ChangeCaptionLbl: Label 'Net Change';
        BalanceCaptionLbl: Label 'Balance';
        PADSTR_____G_L_Account__Indentation___2___G_L_Account__NameCaptionLbl: Label 'Name';
        G_L_Account___Net_Change_CaptionLbl: Label 'Debit';
        G_L_Account___Net_Change__Control22CaptionLbl: Label 'Credit';
        G_L_Account___Balance_at_Date_CaptionLbl: Label 'Debit';
        G_L_Account___Balance_at_Date__Control24CaptionLbl: Label 'Credit';
        SimulationEntriesLbl: Label 'This report includes simulation entries.';
        TotalofPostedTransCaptionLbl: Label 'Total of Posted Transactions';
        AllAmountsAreInLbl: Label 'All amounts are in';

    protected var
        GLFilter: Text;
        PeriodText: Text[30];
        PageGroupNo: Integer;
        ChangeGroupNo: Boolean;
        BlankLineNo: Integer;
        Rounding: Option " ",Tens,Hundreds,Thousands,"Hundred Thousands",Millions;
        RoundingText: Text[50];
        AccountName: Text[250];
        IndentAccountName: Boolean;
        UseAmtsInAddCurr: Boolean;
        TotalDebit: Decimal;
        TotalCredit: Decimal;
        NetChange: Decimal;
        BalanceAtDate: Decimal;
}


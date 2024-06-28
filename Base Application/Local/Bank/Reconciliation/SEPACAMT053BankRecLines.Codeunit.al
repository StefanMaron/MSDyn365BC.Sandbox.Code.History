﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Reconciliation;

codeunit 11521 "SEPA CAMT 053 Bank Rec. Lines"
{
    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun()
    var
        ImpSEPACAMTBankRecLines: Codeunit "Imp. SEPA CAMT Bank Rec. Lines";
        ImportType: Option W1,CH053,CH054;
    begin
        ImpSEPACAMTBankRecLines.SetImportType(ImportType::CH053);
        ImpSEPACAMTBankRecLines.Run(Rec);
    end;
}

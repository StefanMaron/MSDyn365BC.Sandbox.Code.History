// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CashFlow.Account;

enum 841 "Cash Flow Account Type"
{
    AssignmentCompatibility = true;
    Extensible = false;

    value(0; "Entry")
    {
        Caption = 'Entry';
    }
    value(1; Heading)
    {
        Caption = 'Heading';
    }
    value(2; Total)
    {
        Caption = 'Total';
    }
    value(3; "Begin-Total")
    {
        Caption = 'Begin-Total';
    }
    value(4; "End-Total")
    {
        Caption = 'End-Total';
    }
}

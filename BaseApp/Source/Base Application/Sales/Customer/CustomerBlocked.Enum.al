// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.HumanResources.Employee;

enum 5510 "Employee Time Reg. Status"
{
    Extensible = false;
    AssignmentCompatibility = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Ship") { Caption = 'Ship'; }
    value(2; "Invoice") { Caption = 'Invoice'; }
    value(3; "All") { Caption = 'All'; }
}

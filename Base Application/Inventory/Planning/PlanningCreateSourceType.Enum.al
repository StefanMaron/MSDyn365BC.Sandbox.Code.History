// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Planning;

enum 5524 "Planning Create Source Type"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "Purchase") { Caption = 'Purchase'; }
    value(1; "Transfer") { Caption = 'Transfer'; }
    value(2; "Production") { Caption = 'Production'; }
    value(3; "Assembly") { Caption = 'Assembly'; }
}

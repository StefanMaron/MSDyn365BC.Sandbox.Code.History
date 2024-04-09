// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Reflection;

using System.Environment.Configuration;

permissionset 135536 "Rec. Selection Read"
{
    Assignable = true;

    // Include Test Objects
    Permissions = tabledata "Page Data Personalization" = R,
                  table "Record Selection Test Table" = X,
                  tabledata "Record Selection Test Table" = RIMD,
                  page "Record Selection Test Page" = X;
}
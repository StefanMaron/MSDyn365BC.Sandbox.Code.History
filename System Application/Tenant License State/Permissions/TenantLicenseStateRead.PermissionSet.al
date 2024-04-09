// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment;

using System.Security.AccessControl;

permissionset 2300 "Tenant License State - Read"
{
    Assignable = false;

    Permissions = tabledata "Tenant License State" = r;
}
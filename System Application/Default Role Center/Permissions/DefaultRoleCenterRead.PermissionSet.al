// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

using System.Reflection;

permissionset 9171 "Default Role Center - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata AllObjWithCaption = r,
                  tabledata "All Profile" = r;
}
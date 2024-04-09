// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Device;

permissionset 2617 "Printer Management - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = codeunit "Printer Setup" = X,
                  page "Printer Management" = X;
}

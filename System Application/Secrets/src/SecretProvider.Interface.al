#if not CLEAN24
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security;

/// <summary>
/// Abstraction for secret providers.
/// </summary>
interface "Secret Provider"
{

    ObsoleteReason = 'Replaced by Secret Provider v2 with support for SecretValue as SecretText data type.';
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';

    /// <summary>
    /// Retrieves a secret value.
    /// </summary>
    /// <param name="SecretName">The name of the secret to retrieve.</param>
    /// <param name="SecretValue">The value of the secret, or the empty string if the value could not be retrieved.</param>
    /// <returns>True if the secret value could be retrieved; false otherwise.</returns>
    procedure GetSecret(SecretName: Text; var SecretValue: Text): Boolean
}
#endif

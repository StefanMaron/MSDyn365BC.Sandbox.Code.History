// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Excel;

/// <summary>
/// This codeunit provides an interface to create a filter for a specific field for Edit in Excel.
/// </summary>
interface "Edit in Excel Field Filter v2"
{
    Access = Public;

    /// <summary>
    /// Add a filter value
    /// </summary>
    /// <param name="EditInExcelFilterType">The filter type, such as Equal, Greater than.</param>
    /// <param name="FilterValue">The value which the field should be Equal to, Greater than etc.</param>
    procedure AddFilterValueV2(EditInExcelFilterType: Enum "Edit in Excel Filter Type"; FilterValue: Text): Interface "Edit in Excel Field Filter v2"

    /// <summary>
    /// Get a specific filter
    /// </summary>
    /// <param name="Index">The index of the filter.</param>
    /// <param name="EditInExcelFilterType">The filter type, such as Equal, Greater than.</param>
    /// <param name="FilterValue">The value which the field should be Equal to, Greater than etc.</param>
    procedure Get(Index: Integer; var EditinExcelFilterType: Enum "Edit in Excel Filter Type"; var FilterValue: Text)

    /// <summary>
    /// Get the filter collection type
    /// </summary>
    /// <returns>The collection type of the filter</returns>
    procedure GetCollectionType(): Enum "Edit in Excel Filter Collection Type"

    /// <summary>
    /// Remove a specific filter
    /// </summary>
    /// <param name="Index">The index of the filter.</param>
    procedure Remove(Index: Integer)

    /// <summary>
    /// Counts the number of filters
    /// </summary>
    /// <returns>The number of filters</returns>
    procedure Count(): Integer
}

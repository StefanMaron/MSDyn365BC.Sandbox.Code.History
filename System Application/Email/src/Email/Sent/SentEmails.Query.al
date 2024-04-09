// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Security.AccessControl;

/// <summary>
/// Query to get all sent emails and their related records.
/// The query has an one to many relationship between email and the related records.
/// This file contains logic that is identical to the EmailOutbox.Query.al.
/// If changes are made to this file, make sure to update EmailOutbox to.
/// </summary>
query 8889 "Sent Emails"
{
    Access = Internal;
    QueryType = Normal;
    OrderBy = ascending(Message_Id);
    Permissions = tabledata "Sent Email" = r,
                  tabledata "Email Related Record" = r;


    elements
    {
        dataitem(SentEmail; "Sent Email")
        {
            /// <summary>
            /// Email id
            /// </summary>
            column(Id; Id) { }

            /// <summary>
            /// Email message id
            /// </summary>
            column(Message_Id; "Message Id") { }

            /// <summary>
            /// User security id
            /// </summary>
            column(User_Security_Id; "User Security Id") { }

            /// <summary>
            /// Email account id
            /// </summary>
            filter(Account_Id; "Account Id") { }

            /// <summary>
            /// Date and time for when email was sent
            /// </summary>
            filter(Date_Time_Sent; "Date Time Sent") { }

            dataitem(RelatedRecord; "Email Related Record")
            {
                DataItemLink = "Email Message Id" = SentEmail."Message Id";
                SqlJoinType = LeftOuterJoin;

                /// <summary>
                /// Table id for related record
                /// </summary>
                column(Table_Id; "Table Id") { }

                /// <summary>
                /// System id for related record
                /// </summary>
                column(System_Id; "System Id") { }

            }
        }
    }

    procedure GetSentEmails(var SentEmails: Record "Sent Email" temporary)
    var
        SentEmailRecord: Record "Sent Email";
    begin
        if not SentEmails.IsEmpty() then
            SentEmails.DeleteAll();

        CopyFiltersFrom(SentEmails);
        SentEmails.Reset();

        if not Open() then
            exit;

        while Read() do
            if SentEmailRecord.Get(Id) then begin
                SentEmails.SetRange(Id, Id);
                if SentEmails.IsEmpty() then begin
                    SentEmails.TransferFields(SentEmailRecord);
                    SentEmails.Insert();
                end;
                SentEmails.Reset();
            end;
    end;

    procedure ReadUntilNextMessageId(CurrentMessageId: Guid) KeepReading: Boolean
    begin
        KeepReading := Read();
        while KeepReading do begin
            if CurrentMessageId <> Message_Id then
                exit;
            KeepReading := Read();
        end;
    end;

    procedure InsertRecordInto(var SentEmails: Record "Sent Email" temporary)
    var
        SentEmailRecord: Record "Sent Email";
    begin
        if SentEmailRecord.Get(Id) then begin
            SentEmails.TransferFields(SentEmailRecord);
            if SentEmails.Insert() then;
        end;
    end;

    procedure InsertRecordIfAnyRelatedRecords(var SentEmails: Record "Sent Email" temporary) KeepReading: Boolean
    var
        SentEmailRecord: Record "Sent Email";
        RecordRef: RecordRef;
        CurrentMessageId: Guid;
    begin
        KeepReading := true;
        CurrentMessageId := Message_Id;

        // First step is to process already loaded record
        if SentEmailRecord.Get(Id) then
            SentEmails.TransferFields(SentEmailRecord);

        // Keep reading until Read is false or we get a new message id
        // Stop as soon as we get a single permission on a related record
        while KeepReading do begin
            if CurrentMessageId <> Message_Id then
                exit;

            // Intentionally disregard relations to the Users table as every user has access to it
            if (Table_Id <> 0) and (Table_Id <> Database::User) then begin
                RecordRef.Open(Table_Id);
                if RecordRef.ReadPermission() then begin
                    RecordRef.Close();
                    if SentEmails.Insert() then;
                    exit(ReadUntilNextMessageId(CurrentMessageId));
                end;
                RecordRef.Close();
            end;

            KeepReading := Read();
        end;
    end;

    procedure InsertRecordIfAllRelatedRecords(var SentEmails: Record "Sent Email" temporary) KeepReading: Boolean
    var
        SentEmailRecord: Record "Sent Email";
        RecordRef: RecordRef;
        CurrentMessageId: Guid;
        HadRelatedRecord: Boolean;
    begin
        HadRelatedRecord := false;
        KeepReading := true;
        CurrentMessageId := Message_Id;

        // First step is to process already loaded record
        if SentEmailRecord.Get(Id) then
            SentEmails.TransferFields(SentEmailRecord);

        // Keep reading until Read is false or we get a new message id
        while KeepReading do begin
            if (CurrentMessageId <> Message_Id) and HadRelatedRecord then begin
                if SentEmails.Insert() then;
                exit;
            end;

            // Intentionally disregard relations to the Users table as every user has access to it
            if (Table_Id <> 0) and (Table_Id <> Database::User) then begin
                HadRelatedRecord := true;
                RecordRef.Open(Table_Id);
                if not RecordRef.ReadPermission() then begin
                    RecordRef.Close();
                    exit(ReadUntilNextMessageId(CurrentMessageId));
                end;
                RecordRef.Close();
            end;

            KeepReading := Read();
        end;

        // Post fence record.
        // If Read returned false, then CurrentMessageId changed, but while ended
        // and we therefore did not get the change to insert the record
        if HadRelatedRecord then
            if SentEmails.Insert() then;
    end;

    procedure GetSentEmailsIfAccessToAllRelatedRecords(var SentEmails: Record "Sent Email" temporary)
    begin
        GetSentEmailsIfAccessToAllRelatedRecords(SentEmails, false)
    end;

    procedure GetSentEmailsIfAccessToAllRelatedRecords(var SentEmails: Record "Sent Email" temporary; KeepRecords: Boolean)
    var
        KeepReading: Boolean;
        UserSecId: Guid;
    begin
        UserSecId := UserSecurityId();
        KeepReading := true;
        if not KeepRecords then
            if not SentEmails.IsEmpty() then
                SentEmails.DeleteAll();
        CopyFiltersFrom(SentEmails);
        SentEmails.Reset();

        //
        // Each row returned in the SQL statement is read one at the time
        // We need to make sure that all related records to the same message id is accessible to the user
        //
        if not Open() then
            exit;

        KeepReading := Read();
        while KeepReading do begin

            // If user is the owner of email we simply insert this sent email
            // And read until next message id
            while User_Security_Id = UserSecId do begin
                InsertRecordInto(SentEmails);
                KeepReading := ReadUntilNextMessageId(Message_Id);
                if not KeepReading then
                    exit;
            end;

            // Process message and insert
            KeepReading := InsertRecordIfAllRelatedRecords(SentEmails);
        end;
    end;

    procedure GetSentEmailsIfAccessToAnyRelatedRecords(var SentEmails: Record "Sent Email" temporary)
    begin
        GetSentEmailsIfAccessToAnyRelatedRecords(SentEmails, false)
    end;

    procedure GetSentEmailsIfAccessToAnyRelatedRecords(var SentEmails: Record "Sent Email" temporary; KeepRecords: Boolean)
    var
        KeepReading: Boolean;
        UserSecId: Guid;
    begin
        UserSecId := UserSecurityId();
        KeepReading := true;
        if not KeepRecords then
            if not SentEmails.IsEmpty() then
                SentEmails.DeleteAll();
        CopyFiltersFrom(SentEmails);
        SentEmails.Reset();

        //
        // Each row returned in the SQL statement is read one at the time
        // We need to make sure that any related records to the same message id is accessible to the user
        //
        if not Open() then
            exit;

        KeepReading := Read();
        while KeepReading do begin

            // If user is the owner of email we simply insert this sent email
            // And read until next message id
            while User_Security_Id = UserSecId do begin
                InsertRecordInto(SentEmails);
                KeepReading := ReadUntilNextMessageId(Message_Id);
                if not KeepReading then
                    exit;
            end;

            // Process message and insert
            KeepReading := InsertRecordIfAnyRelatedRecords(SentEmails);
        end;
    end;

    local procedure CopyFiltersFrom(var SentEmail: Record "Sent Email" temporary)
    begin
        // In certain localizations, the filters do not work with filter tokens.
        // Fx. MX localization. GetFilter() output is "17/07/22 04:01:25.251 p. m...17/07/22 04:01:25.251 p. m."
        // Which will fail with filter tokens as it will split into "17/07/22 04:01:25.251 p. m" and "".17/07/22 04:01:25.251 p. m."". The second is an invalid datetime.
        if SentEmail.GetFilter("Date Time Sent") <> '' then
            SetRange(Date_Time_Sent, SentEmail.GetRangeMin("Date Time Sent"), SentEmail.GetRangeMax("Date Time Sent"));

        SetFilter(Account_Id, SentEmail.GetFilter("Account Id"));
        SetFilter(User_Security_Id, SentEmail.GetFilter("User Security Id"));
    end;
}
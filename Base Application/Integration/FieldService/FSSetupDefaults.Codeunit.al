// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN25
namespace Microsoft.Integration.FieldService;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Shipping;
using Microsoft.Integration.Dataverse;
using Microsoft.Integration.D365Sales;
using Microsoft.Integration.SyncEngine;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;
using System.Reflection;
using System.Threading;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Projects.Project.Journal;
using System.Environment.Configuration;
using System.Media;

codeunit 6404 "FS Setup Defaults"
{
    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
    ObsoleteState = Pending;
    ObsoleteTag = '25.0';

    var
        CRMProductName: Codeunit "CRM Product Name";
        JobQueueCategoryLbl: Label 'BCI INTEG', Locked = true;
        OptionJobQueueCategoryLbl: Label 'BCI OPTION', Locked = true;
        CustomerTableMappingNameTxt: Label 'CUSTOMER', Locked = true;
        CategoryTok: Label 'AL Field Service Integration', Locked = true;
        VendorTableMappingNameTxt: Label 'VENDOR', Locked = true;
        JobQueueEntryNameTok: Label ' %1 - %2 synchronization job.', Comment = '%1 = The Integration Table Name to synchronized (ex. CUSTOMER), %2 = CRM product name';
        UncoupleJobQueueEntryNameTok: Label ' %1 uncouple job.', Comment = '%1 = Integration mapping description, for example, CUSTOMER <-> CRM Account';
        CoupleJobQueueEntryNameTok: Label ' %1 coupling job.', Comment = '%1 = Integration mapping description, for example, CUSTOMER <-> CRM Account';
        IntegrationTablePrefixTok: Label 'Dynamics CRM', Comment = 'Product name', Locked = true;
        CRMConnectionSetupTxt: Label 'Set up %1 connection', Comment = '%1 = CRM product name';
        VideoUrlSetupCRMConnectionTxt: Label '', Locked = true;

    internal procedure ResetConfiguration(var FSConnectionSetup: Record "FS Connection Setup")
    var
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetConfiguration(FSConnectionSetup, IsHandled);
        if IsHandled then
            exit;

        CDSIntegrationMgt.RegisterConnection();
        CDSIntegrationMgt.ActivateConnection();

        ResetProjectTaskMapping(FSConnectionSetup, 'PROJECTTASK', true);
        ResetProjectJournalLineWOProductMapping(FSConnectionSetup, 'PJLINE-WORDERPRODUCT', true);
        ResetProjectJournalLineWOServiceMapping(FSConnectionSetup, 'PJLINE-WORDERSERVICE', true);
        ResetServiceItemCustomerAssetMapping(FSConnectionSetup, 'SVCITEM-CUSTASSET', true);
        ResetResourceBookableResourceMapping(FSConnectionSetup, 'RESOURCE-BOOKABLERSC', true);
        SetCustomIntegrationsTableMappings(FSConnectionSetup);
    end;

    internal procedure ResetProjectTaskMapping(var FSConnectionSetup: Record "FS Connection Setup"; IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        JobTask: Record "Job Task";
        FSProjectTask: Record "FS Project Task";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetProjectTaskMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        JobTask.Reset();
        JobTask.SetRange("Job Task Type", JobTask."Job Task Type"::Posting);
        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          DATABASE::"Job Task", DATABASE::"FS Project Task",
          FSProjectTask.FieldNo(ProjectTaskId), FSProjectTask.FieldNo(ModifiedOn),
          '', '', false);

        IntegrationTableMapping.SetTableFilter(
          GetTableFilterFromView(DATABASE::"Job Task", JobTask.TableCaption(), JobTask.GetView()));
        if not ShouldResetServiceItemMapping() then
            IntegrationTableMapping."Dependency Filter" := 'CUSTOMER|RESOURCE-BOOKABLERSC'
        else
            IntegrationTableMapping."Dependency Filter" := 'CUSTOMER|RESOURCE-BOOKABLERSC|SVCITEM-CUSTASSET';
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobTask.FieldNo("Job No."),
          FSProjectTask.FieldNo(ProjectNumber),
          IntegrationFieldMapping.Direction::ToIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobTask.FieldNo("Job Task No."),
          FSProjectTask.FieldNo(ProjectTaskNumber),
          IntegrationFieldMapping.Direction::ToIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobTask.FieldNo(Description),
          FSProjectTask.FieldNo(Description),
          IntegrationFieldMapping.Direction::ToIntegrationTable,
          '', true, false);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetProjectJournalLineWOProductMapping(var FSConnectionSetup: Record "FS Connection Setup"; IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        FSWorkOrderProduct: Record "FS Work Order Product";
        JobJournalLine: Record "Job Journal Line";
        CDSCompany: Record "CDS Company";
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        IsHandled: Boolean;
        EmptyGuid: Guid;
    begin
        IsHandled := false;
        OnBeforeResetProjectJournalLineWOProductMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FSWorkOrderProduct.Reset();
        FSWorkOrderProduct.SetRange(StateCode, FSWorkOrderProduct.StateCode::Active);
        FSWorkOrderProduct.SetFilter(ProjectTask, '<>' + Format(EmptyGuid));
        case FSConnectionSetup."Line Synch. Rule" of
            "FS Work Order Line Synch. Rule"::LineUsed:
                FSWorkOrderProduct.SetRange(LineStatus, FSWorkOrderProduct.LineStatus::Used);
            "FS Work Order Line Synch. Rule"::WorkOrderCompleted:
                FSWorkOrderProduct.SetFilter(WorkOrderStatus, Format(FSWorkOrderProduct.WorkOrderStatus::Completed) + '|' + Format(FSWorkOrderProduct.WorkOrderStatus::Posted));
        end;
        FSWorkOrderProduct.SetFilter(ProjectTask, '<>' + Format(EmptyGuid));
        if CDSIntegrationMgt.GetCDSCompany(CDSCompany) then
            FSWorkOrderProduct.SetRange(CompanyId, CDSCompany.CompanyId);

        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          DATABASE::"Job Journal Line", DATABASE::"FS Work Order Product",
          FSWorkOrderProduct.FieldNo(WorkOrderProductId), FSWorkOrderProduct.FieldNo(ModifiedOn),
          '', '', false);

        IntegrationTableMapping.SetIntegrationTableFilter(
          GetTableFilterFromView(DATABASE::"FS Work Order Product", FSWorkOrderProduct.TableCaption(), FSWorkOrderProduct.GetView()));
        IntegrationTableMapping."Dependency Filter" := 'CUSTOMER|ITEM-PRODUCT';
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo(Description),
          FSWorkOrderProduct.FieldNo(Name),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo("External Document No."),
          FSWorkOrderProduct.FieldNo(WorkOrderName),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo(Quantity),
          FSWorkOrderProduct.FieldNo(Quantity),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo("Qty. to Transfer to Invoice"),
          FSWorkOrderProduct.FieldNo(QtyToBill),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo("Currency Code"),
          FSWorkOrderProduct.FieldNo(TransactionCurrencyId),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        OnAfterResetProjectJournalLineWOProductMapping(IntegrationTableMappingName);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetProjectJournalLineWOServiceMapping(var FSConnectionSetup: Record "FS Connection Setup"; IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        FSWorkOrderService: Record "FS Work Order Service";
        JobJournalLine: Record "Job Journal Line";
        CDSCompany: Record "CDS Company";
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        IsHandled: Boolean;
        EmptyGuid: Guid;
    begin
        IsHandled := false;
        OnBeforeResetProjectJournalLineWOServiceMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FSWorkOrderService.Reset();
        FSWorkOrderService.SetRange(StateCode, FSWorkOrderService.StateCode::Active);
        FSWorkOrderService.SetFilter(ProjectTask, '<>' + Format(EmptyGuid));
        case FSConnectionSetup."Line Synch. Rule" of
            "FS Work Order Line Synch. Rule"::LineUsed:
                FSWorkOrderService.SetRange(LineStatus, FSWorkOrderService.LineStatus::Used);
            "FS Work Order Line Synch. Rule"::WorkOrderCompleted:
                FSWorkOrderService.SetFilter(WorkOrderStatus, Format(FSWorkOrderService.WorkOrderStatus::Completed) + '|' + Format(FSWorkOrderService.WorkOrderStatus::Posted));
        end;
        if CDSIntegrationMgt.GetCDSCompany(CDSCompany) then
            FSWorkOrderService.SetRange(CompanyId, CDSCompany.CompanyId);
        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          DATABASE::"Job Journal Line", DATABASE::"FS Work Order Service",
          FSWorkOrderService.FieldNo(WorkOrderServiceId), FSWorkOrderService.FieldNo(ModifiedOn),
          '', '', false);

        IntegrationTableMapping.SetIntegrationTableFilter(
          GetTableFilterFromView(DATABASE::"FS Work Order Service", FSWorkOrderService.TableCaption(), FSWorkOrderService.GetView()));

        IntegrationTableMapping."Dependency Filter" := 'CUSTOMER|ITEM-PRODUCT|RESOURCE-BOOKABLERSC';
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo(Description),
          FSWorkOrderService.FieldNo(Name),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo("External Document No."),
          FSWorkOrderService.FieldNo(WorkOrderName),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo(Quantity),
          FSWorkOrderService.FieldNo(Duration),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo("Qty. to Transfer to Invoice"),
          FSWorkOrderService.FieldNo(DurationToBill),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo("Currency Code"),
          FSWorkOrderService.FieldNo(TransactionCurrencyId),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        OnAfterResetProjectJournalLineWOServiceMapping(IntegrationTableMappingName);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetResourceBookableResourceMapping(var FSConnectionSetup: Record "FS Connection Setup"; IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        FSBookableResource: Record "FS Bookable Resource";
        Resource: Record Resource;
        CDSCompany: Record "CDS Company";
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        IsHandled: Boolean;
        EmptyGuid: Guid;
    begin
        IsHandled := false;
        OnBeforeResetResourceBookableResourceMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        Resource.SetRange(Blocked, false);
        Resource.SetRange("Use Time Sheet", false);
        Resource.SetRange("Base Unit of Measure", FSConnectionSetup."Hour Unit of Measure");

        FSBookableResource.Reset();
        FSBookableResource.SetRange(StateCode, FSBookableResource.StateCode::Active);
        FSBookableResource.SetFilter(ResourceType, Format(FSBookableResource.ResourceType::Generic) + '|' + Format(FSBookableResource.ResourceType::Account) + '|' + Format(FSBookableResource.ResourceType::Equipment));
        if CDSIntegrationMgt.GetCDSCompany(CDSCompany) then
            FSBookableResource.SetFilter(CompanyId, CDSCompany.CompanyId + '|' + Format(EmptyGuid));
        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          DATABASE::Resource, DATABASE::"FS Bookable Resource",
          FSBookableResource.FieldNo(BookableResourceId), FSBookableResource.FieldNo(ModifiedOn),
          '', '', true);

        IntegrationTableMapping.SetTableFilter(
          GetTableFilterFromView(DATABASE::Resource, Resource.TableCaption(), Resource.GetView()));
        IntegrationTableMapping.SetIntegrationTableFilter(
          GetTableFilterFromView(DATABASE::"FS Bookable Resource", FSBookableResource.TableCaption(), FSBookableResource.GetView()));
        IntegrationTableMapping."Dependency Filter" := 'CUSTOMER|ITEM-PRODUCT';
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          Resource.FieldNo(Name),
          FSBookableResource.FieldNo(Name),
          IntegrationFieldMapping.Direction::Bidirectional,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          Resource.FieldNo("Vendor No."),
          FSBookableResource.FieldNo(AccountId),
          IntegrationFieldMapping.Direction::Bidirectional,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          Resource.FieldNo("Unit Cost"),
          FSBookableResource.FieldNo(HourlyRate),
          IntegrationFieldMapping.Direction::Bidirectional,
          '', true, false);

        OnAfterResetResourceBookableResourceMapping(IntegrationTableMappingName);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetServiceItemCustomerAssetMapping(var FSConnectionSetup: Record "FS Connection Setup"; IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        FSCustomerAsset: Record "FS Customer Asset";
        ServiceItem: Record Microsoft.Service.Item."Service Item";
        CDSCompany: Record "CDS Company";
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        EmptyGuid: Guid;
        IsHandled: Boolean;
    begin
        if not ShouldResetServiceItemMapping() then begin
            Session.LogMessage('0000MMQ', 'The current company is not eligible to synchronize service items.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        IsHandled := false;
        OnBeforeResetServiceItemCustomerAssetMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FSCustomerAsset.Reset();
        FSCustomerAsset.SetRange(StateCode, FSCustomerAsset.StateCode::Active);
        if CDSIntegrationMgt.GetCDSCompany(CDSCompany) then
            FSCustomerAsset.SetFilter(CompanyId, CDSCompany.CompanyId + '|' + EmptyGuid);

        ServiceItem.Reset();
        ServiceItem.SetRange(Blocked, ServiceItem.Blocked::" ");

        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          DATABASE::Microsoft.Service.Item."Service Item", DATABASE::"FS Customer Asset",
          FSCustomerAsset.FieldNo(CustomerAssetId), FSCustomerAsset.FieldNo(ModifiedOn),
          '', '', true);

        IntegrationTableMapping.SetIntegrationTableFilter(
          GetTableFilterFromView(DATABASE::"FS Customer Asset", FSCustomerAsset.TableCaption(), FSCustomerAsset.GetView()));
        IntegrationTableMapping.SetTableFilter(
          GetTableFilterFromView(DATABASE::Microsoft.Service.Item."Service Item", ServiceItem.TableCaption(), ServiceItem.GetView()));
        IntegrationTableMapping."Dependency Filter" := 'CUSTOMER|ITEM-PRODUCT';
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          ServiceItem.FieldNo(Description),
          FSCustomerAsset.FieldNo(Name),
          IntegrationFieldMapping.Direction::Bidirectional,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          ServiceItem.FieldNo("Customer No."),
          FSCustomerAsset.FieldNo(Account),
          IntegrationFieldMapping.Direction::Bidirectional,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          ServiceItem.FieldNo("Item No."),
          FSCustomerAsset.FieldNo(Product),
          IntegrationFieldMapping.Direction::Bidirectional,
          '', true, false);

        OnAfterResetServiceItemCustomerAssetMapping(IntegrationTableMappingName);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    local procedure ShouldResetServiceItemMapping(): Boolean
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        exit(ApplicationAreaMgmtFacade.IsPremiumExperienceEnabled());
    end;

    local procedure InsertIntegrationTableMapping(var IntegrationTableMapping: Record "Integration Table Mapping"; MappingName: Code[20]; TableNo: Integer; IntegrationTableNo: Integer; IntegrationTableUIDFieldNo: Integer; IntegrationTableModifiedFieldNo: Integer; TableConfigTemplateCode: Code[10]; IntegrationTableConfigTemplateCode: Code[10]; SynchOnlyCoupledRecords: Boolean)
    var
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        UncoupleCodeunitId: Integer;
        Direction: Integer;
    begin
        Direction := GetDefaultDirection(TableNo);
        if Direction in [IntegrationTableMapping.Direction::ToIntegrationTable, IntegrationTableMapping.Direction::Bidirectional] then
            if CDSIntegrationMgt.HasCompanyIdField(IntegrationTableNo) then
                UncoupleCodeunitId := Codeunit::"CDS Int. Table Uncouple";
        IntegrationTableMapping.CreateRecord(MappingName, TableNo, IntegrationTableNo, IntegrationTableUIDFieldNo,
          IntegrationTableModifiedFieldNo, TableConfigTemplateCode, IntegrationTableConfigTemplateCode,
          SynchOnlyCoupledRecords, Direction, IntegrationTablePrefixTok,
          Codeunit::"CRM Integration Table Synch.", UncoupleCodeunitId);
    end;

    local procedure InsertIntegrationFieldMapping(IntegrationTableMappingName: Code[20]; TableFieldNo: Integer; IntegrationTableFieldNo: Integer; SynchDirection: Option; ConstValue: Text; ValidateField: Boolean; ValidateIntegrationTableField: Boolean)
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
    begin
        IntegrationFieldMapping.CreateRecord(IntegrationTableMappingName, TableFieldNo, IntegrationTableFieldNo, SynchDirection,
          ConstValue, ValidateField, ValidateIntegrationTableField);
    end;

    [Scope('OnPrem')]
    procedure CreateUncoupleJobQueueEntry(var IntegrationTableMapping: Record "Integration Table Mapping"): Boolean
    begin
        exit(CreateJobQueueEntry(IntegrationTableMapping, Codeunit::"Int. Uncouple Job Runner", StrSubstNo(UncoupleJobQueueEntryNameTok, IntegrationTableMapping.GetTempDescription())));
    end;

    [Scope('OnPrem')]
    procedure CreateCoupleJobQueueEntry(var IntegrationTableMapping: Record "Integration Table Mapping"): Boolean
    begin
        exit(CreateJobQueueEntry(IntegrationTableMapping, Codeunit::"Int. Coupling Job Runner", StrSubstNo(CoupleJobQueueEntryNameTok, IntegrationTableMapping.GetTempDescription())));
    end;

    procedure CreateJobQueueEntry(IntegrationTableMapping: Record "Integration Table Mapping"): Boolean
    begin
        exit(CreateJobQueueEntry(IntegrationTableMapping, StrSubstNo(JobQueueEntryNameTok, IntegrationTableMapping.GetTempDescription(), CRMProductName.CDSServiceName())));
    end;

    internal procedure CreateJobQueueEntry(IntegrationTableMapping: Record "Integration Table Mapping"; ServiceName: Text): Boolean
    begin
        exit(CreateJobQueueEntry(IntegrationTableMapping, Codeunit::"Integration Synch. Job Runner", StrSubstNo(JobQueueEntryNameTok, IntegrationTableMapping.GetTempDescription(), ServiceName)));
    end;

    local procedure CreateJobQueueEntry(var IntegrationTableMapping: Record "Integration Table Mapping"; JobCodeunitId: Integer; JobDescription: Text): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime() + 1000;
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", JobCodeunitId);
        JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
        JobQueueEntry.SetRange("Job Queue Category Code", JobQueueCategoryLbl);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::Ready);
        JobQueueEntry.SetFilter("Earliest Start Date/Time", '<=%1', StartTime);
        if not JobQueueEntry.IsEmpty() then begin
            JobQueueEntry.DeleteTasks();
            Commit();
        end;

        JobQueueEntry.Init();
        Clear(JobQueueEntry.ID); // "Job Queue - Enqueue" is to define new ID
        JobQueueEntry."Earliest Start Date/Time" := StartTime;
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := JobCodeunitId;
        JobQueueEntry."Record ID to Process" := IntegrationTableMapping.RecordId();
        JobQueueEntry."Run in User Session" := false;
        JobQueueEntry."Notify On Success" := false;
        JobQueueEntry."Maximum No. of Attempts to Run" := 2;
        JobQueueEntry."Job Queue Category Code" := JobQueueCategoryLbl;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry."Rerun Delay (sec.)" := 30;
        JobQueueEntry.Description := CopyStr(JobDescription, 1, MaxStrLen(JobQueueEntry.Description));
        OnCreateJobQueueEntryOnBeforeJobQueueEnqueue(JobQueueEntry, IntegrationTableMapping, JobCodeunitId, JobDescription);
        exit(Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry))
    end;

    local procedure RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping: Record "Integration Table Mapping"; IntervalInMinutes: Integer; ShouldRecreateJobQueueEntry: Boolean; InactivityTimeoutPeriod: Integer)
    begin
        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, IntervalInMinutes, ShouldRecreateJobQueueEntry, InactivityTimeoutPeriod, CRMProductName.CDSServiceName(), false);
    end;

    internal procedure RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping: Record "Integration Table Mapping"; IntervalInMinutes: Integer; ShouldRecreateJobQueueEntry: Boolean; InactivityTimeoutPeriod: Integer; ServiceName: Text; IsOption: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
        JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
        JobQueueEntry.DeleteTasks();

        JobQueueEntry.InitRecurringJob(IntervalInMinutes);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Integration Synch. Job Runner";
        JobQueueEntry."Record ID to Process" := IntegrationTableMapping.RecordId();
        JobQueueEntry."Run in User Session" := false;
        JobQueueEntry.Description :=
          CopyStr(StrSubstNo(JobQueueEntryNameTok, IntegrationTableMapping.Name, ServiceName), 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueEntry."Maximum No. of Attempts to Run" := 10;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry."Rerun Delay (sec.)" := 30;
        JobQueueEntry."Inactivity Timeout Period" := InactivityTimeoutPeriod;
        if IsOption then
            JobQueueEntry."Job Queue Category Code" := OptionJobQueueCategoryLbl;
        if ShouldRecreateJobQueueEntry then
            Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry)
        else
            JobQueueEntry.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Setup Defaults", 'OnGetCDSTableNo', '', false, false)]
    local procedure ReturnProxyTableNoOnGetCDSTableNo(BCTableNo: Integer; var CDSTableNo: Integer; var handled: Boolean)
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if handled then
            exit;

        if not CDSConnectionSetup.Get() then
            exit;

        if not CDSConnectionSetup."Is Enabled" then
            exit;

        case BCTableNo of
            DATABASE::Contact:
                CDSTableNo := DATABASE::"CRM Contact";
            DATABASE::Currency:
                CDSTableNo := DATABASE::"CRM Transactioncurrency";
            DATABASE::Customer,
            DATABASE::Vendor:
                CDSTableNo := DATABASE::"CRM Account";
            DATABASE::"Salesperson/Purchaser":
                CDSTableNo := DATABASE::"CRM Systemuser";
            DATABASE::"Payment Terms":
                CDSTableNo := DATABASE::"CRM Payment Terms";
            DATABASE::"Shipment Method":
                CDSTableNo := DATABASE::"CRM Freight Terms";
            DATABASE::"Shipping Agent":
                CDSTableNo := DATABASE::"CRM Shipping Method";
        end;

        if CDSTableNo <> 0 then
            handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Setup Defaults", 'OnAddEntityTableMapping', '', false, false)]
    local procedure AddProxyTablesOnAddEntityTableMapping(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if not CDSConnectionSetup.Get() then
            exit;

        if not CDSConnectionSetup."Is Enabled" then
            exit;

        TempNameValueBuffer.ID := TempNameValueBuffer.Count() + 1;
        TempNameValueBuffer.Name := 'account';
        TempNameValueBuffer.Value := Format(Database::Vendor);
        TempNameValueBuffer.Insert();
    end;

    procedure GetDefaultDirection(NAVTableID: Integer): Integer
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        case NAVTableID of
            DATABASE::Microsoft.Service.Item."Service Item",
            DATABASE::"Work Type",
            DATABASE::"Resource":
                exit(IntegrationTableMapping.Direction::Bidirectional);
            DATABASE::"Job Task":
                exit(IntegrationTableMapping.Direction::ToIntegrationTable);
            DATABASE::"Job Journal Line":
                exit(IntegrationTableMapping.Direction::FromIntegrationTable);
        end;
    end;

    local procedure GetTableFilterFromView(TableID: Integer; Caption: Text; View: Text): Text
    var
        FilterBuilder: FilterPageBuilder;
    begin
        FilterBuilder.AddTable(Caption, TableID);
        FilterBuilder.SetView(Caption, View);
        exit(FilterBuilder.GetView(Caption, false));
    end;

    procedure GetPrioritizedMappingList(var NameValueBuffer: Record "Name/Value Buffer")
    // TO DO: This is needed for "Synchronize Modified Records" that we should add
    var
        "Field": Record "Field";
        IntegrationTableMapping: Record "Integration Table Mapping";
        NextPriority: Integer;
    begin
        NextPriority := 1;

        // 1) From CRM Systemusers
        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, 0, DATABASE::"CRM Systemuser");
        // 2) From Currency
        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, DATABASE::Currency, 0);
        // 3) To/From Customers/CRM Accounts
        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, DATABASE::Customer, DATABASE::"CRM Account");
        // 4)  Vendor
        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, DATABASE::Vendor, DATABASE::"CRM Account");
        // 5) To/From Contacts/CRM Contacts
        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, DATABASE::Contact, DATABASE::"CRM Contact");

        IntegrationTableMapping.Reset();
        IntegrationTableMapping.SetFilter("Parent Name", '=''''');
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::Dataverse);
        IntegrationTableMapping.SetRange("Int. Table UID Field Type", Field.Type::GUID);
        if IntegrationTableMapping.FindSet() then
            repeat
                AddPrioritizedMappingToList(NameValueBuffer, NextPriority, IntegrationTableMapping.Name);
            until IntegrationTableMapping.Next() = 0;
    end;

    local procedure AddPrioritizedMappingsToList(var NameValueBuffer: Record "Name/Value Buffer"; var Priority: Integer; TableID: Integer; IntegrationTableID: Integer)
    var
        "Field": Record "Field";
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        IntegrationTableMapping.Reset();
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        if TableID > 0 then
            IntegrationTableMapping.SetRange("Table ID", TableID);
        if IntegrationTableID > 0 then
            IntegrationTableMapping.SetRange("Integration Table ID", IntegrationTableID);
        IntegrationTableMapping.SetRange("Int. Table UID Field Type", Field.Type::GUID);
        if IntegrationTableMapping.FindSet() then
            repeat
                AddPrioritizedMappingToList(NameValueBuffer, Priority, IntegrationTableMapping.Name);
            until IntegrationTableMapping.Next() = 0;
    end;

    local procedure AddPrioritizedMappingToList(var NameValueBuffer: Record "Name/Value Buffer"; var Priority: Integer; MappingName: Code[20])
    begin
        NameValueBuffer.SetRange(Value, MappingName);

        if not NameValueBuffer.FindFirst() then begin
            NameValueBuffer.Init();
            NameValueBuffer.ID := Priority;
            NameValueBuffer.Name := Format(Priority);
            NameValueBuffer.Value := MappingName;
            NameValueBuffer.Insert();
            Priority := Priority + 1;
        end;

        NameValueBuffer.Reset();
    end;

    [Scope('Cloud')]
    procedure GetCustomerTableMappingName(): Text
    begin
        exit(CustomerTableMappingNameTxt);
    end;

    [Scope('Cloud')]
    procedure GetVendorTableMappingName(): Text
    begin
        exit(VendorTableMappingNameTxt);
    end;

    internal procedure RegisterAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        Info: ModuleInfo;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        NavApp.GetCurrentModuleInfo(Info);
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, PAGE::"FS Connection Setup Wizard") then
            GuidedExperience.InsertAssistedSetup(
                StrSubstNo(CRMConnectionSetupTxt, CRMProductName.FSServiceName()), CopyStr(StrSubstNo(CRMConnectionSetupTxt, CRMProductName.FSServiceName()), 1, 50), '',
                0, ObjectType::Page, PAGE::"FS Connection Setup Wizard", AssistedSetupGroup::Customize, VideoUrlSetupCRMConnectionTxt, VideoCategory::Customize, '');
    end;

    internal procedure SetCustomIntegrationsTableMappings(FSConnectionSetup: Record "FS Connection Setup")
    begin
        OnAfterResetConfiguration(FSConnectionSetup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetConfiguration(FSConnectionSetup: Record "FS Connection Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetProjectJournalLineWOProductMapping(IntegrationTableMappingName: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetProjectJournalLineWOServiceMapping(IntegrationTableMappingName: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetServiceItemCustomerAssetMapping(IntegrationTableMappingName: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetResourceBookableResourceMapping(var IntegrationTableMappingName: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetConfiguration(var FSConnectionSetup: Record "FS Connection Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetProjectJournalLineWOProductMapping(var IntegrationTableMappingName: Code[20]; var ShouldRecreateJobQueueEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetProjectJournalLineWOServiceMapping(var IntegrationTableMappingName: Code[20]; var ShouldRecreateJobQueueEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetServiceItemCustomerAssetMapping(var IntegrationTableMappingName: Code[20]; var ShouldRecreateJobQueueEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetProjectTaskMapping(var IntegrationTableMappingName: Code[20]; var ShouldRecreateJobQueueEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetResourceBookableResourceMapping(var IntegrationTableMappingName: Code[20]; var ShouldRecreateJobQueueEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateJobQueueEntryOnBeforeJobQueueEnqueue(var JobQueueEntry: Record "Job Queue Entry"; var IntegrationTableMapping: Record "Integration Table Mapping"; JobCodeunitId: Integer; JobDescription: Text)
    begin
    end;
}
#endif
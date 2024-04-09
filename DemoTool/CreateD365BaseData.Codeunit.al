codeunit 119202 "Create D365 Base Data"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"Create Profiles");
        CreatePermissions;
        CreateWebServices;
        SetupAPIs;
        SetupApplicationArea;
        Codeunit.Run(Codeunit::"Create Getting Started Data");
        Codeunit.Run(Codeunit::"Create Media Repository");
        Codeunit.Run(Codeunit::"Create Excel Templates");
        Codeunit.Run(Codeunit::"Create Late Payment Model");
        CODEUNIT.Run(CODEUNIT::"Create SAF-T Media");
    end;

    var
        // Note: Those strings are used only for upgrade from 14.x to 15.0 for translations, and should be deleted afterwards
        AccountantTxt: Label 'Accountant';
        OrderProcessorTxt: Label 'Order Processor';
        SecurityAdministratorTxt: Label 'Security Administrator';
        BusinessManagerIDTxt: Label 'Business Manager';
        SalesRlshpMgrIDTxt: Label 'Sales and Relationship Manager';
        O365SalesTxt: Label 'O365 Sales';
        ProjectManagerTxt: Label 'PROJECT MANAGER';
        TeamMemberTxt: Label 'TEAM MEMBER', Comment = 'Please translate all caps';
        InvoicingTxt: Label 'Invoicing';
        AccountantPortalTxt: Label 'Accountant Portal';
        AccountingManagerTxt: Label 'Accounting Manager';
        AccountingServicesTxt: Label 'Accounting Services';
        APCoordinatorTxt: Label 'AP Coordinator';
        ARAdministratorTxt: Label 'AR Administrator';
        BookkeeperTxt: Label 'Bookkeeper';
        DispatcherTxt: Label 'Dispatcher';
        ITManagerTxt: Label 'IT Manager';
        MachineOperatorTxt: Label 'Machine Operator';
        OutboundTechnicianTxt: Label 'Outbound Technician';
        PresidentTxt: Label 'President';
        PresidentSmallBusTxt: Label 'President - Small Business';
        ProductionPlannerTxt: Label 'Production Planner';
        PurchasingAgentTxt: Label 'Purchasing Agent';
        RapidstartServicesTxt: Label 'RapidStart Services';
        ResourceManagerTxt: Label 'Resource Manager';
        SalesManagerTxt: Label 'Sales Manager';
        ShippingAndReceivingTxt: Label 'Shipping and Receiving';
        ShippingAndReceivingWMSTxt: Label 'Shipping and Receiving - WMS';
        ShopSupervisorTxt: Label 'Shop Supervisor';
        ShopSupervisorFoundTxt: Label 'Shop Supervisor - Foundation';
        WHSWorkerWMSTxt: Label 'Warehouse Worker - WMS';
    // End of strings used for upgrade from 14.x to 15.0

    local procedure CreatePermissions()
    begin
        Codeunit.Run(Codeunit::"Create Default Permissions");
    end;

    local procedure CreateWebServices()
    var
        WebService: Record "Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
        CreateWebServices: Codeunit "Create Web Services";
    begin
        WebService.DeleteAll();

        WebServiceManagement.CreateWebService(
          WebService."Object Type"::Codeunit, Codeunit::"Company Setup Service", 'CompanySetupService', true);

        WebServiceManagement.CreateWebService(
          WebService."Object Type"::Codeunit, Codeunit::"Exchange Service Setup", 'ExchangeServiceSetup', true);
#if not CLEAN21
        WebServiceManagement.CreateWebService(
          WebService."Object Type"::Page, Page::"O365 Sales Graph", 'C2Graph', true);

        WebServiceManagement.CreateWebService(
          WebService."Object Type"::Page, Page::"Sales Invoice Document API", 'InvoiceDocument', true);
        WebServiceManagement.CreateWebService(
          WebService."Object Type"::Page, Page::"Sales Invoice Reminder API", 'InvoiceReminder', true);
#endif
        WebServiceManagement.CreateWebService(
          WebService."Object Type"::Codeunit, Codeunit::"Page Summary Provider", 'SummaryProvider', true);

        WebServiceManagement.CreateWebService(
          WebService."Object Type"::Codeunit, Codeunit::"Page Action Provider", 'PageActionProvider', true);

        CreateWebServices.CreatePowerBIWebServices();
        CreateWebServices.CreateSegmentWebService();
        CreateWebServices.CreateJobWebServices();
        CreateWebServices.CreatePowerBITenantWebServices();
        CreateWebServices.CreateAccountantPortalWebServices();
        CreateWebServices.CreateWorkflowWebhookWebServices();
        CreateWebServices.CreateExcelTemplateWebServices();
    end;

    local procedure SetupApplicationArea()
    var
        ExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(ExperienceTierSetup.FieldCaption(Essential));
    end;

    local procedure SetupAPIs()
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        GraphMgtGeneralTools.ApiSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Graph Mgt - General Tools", 'OnGetIsAPIEnabled', '', false, false)]
    local procedure GetIsAPIEnabled(var Handled: Boolean; var IsAPIEnabled: Boolean)
    begin
        Handled := true;
        IsAPIEnabled := true;
    end;
}


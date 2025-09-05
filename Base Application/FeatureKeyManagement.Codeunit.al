namespace System.Environment.Configuration;

#if not CLEAN25
using Microsoft.Pricing.Calculation;
#endif

codeunit 265 "Feature Key Management"
{
    Access = Internal;
    SingleInstance = true;

    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        FeatureTelemetry: Codeunit System.Telemetry."Feature Telemetry";
        AutomaticAccountCodesTxt: Label 'AutomaticAccountCodes', Locked = true;
        SIEAuditFileExportTxt: Label 'SIEAuditFileExport', Locked = true;
#if not CLEAN24
        PhysInvtOrderPackageTrackingTxt: Label 'PhysInvtOrderPackageTracking', Locked = true;
#endif
#if not CLEAN24
        GLCurrencyRevaluationTxt: Label 'GLCurrencyRevaluation', Locked = true;
#endif
#if not CLEAN26
        ManufacturingFlushingMethodActivateManualWithoutPickLbl: Label 'Manufacturing_FlushingMethod_ActivateManualWoPick', Locked = true;
        ManufacturingFlushingMethodActivateManualWithoutPick, ManufacturingFlushingMethodActivateManualWithoutPickRead, MockEnabledManufacturingFlushingMethodActivateManualWithoutPick : Boolean;
#endif
        ConcurrentWarehousingPostingLbl: Label 'ConcurrentWarehousingPosting', Locked = true;
        ConcurrentWarehousingPosting: Boolean;
        ConcurrentWarehousingPostingRead: Boolean;
        ConcurrentInventoryPostingLbl: Label 'ConcurrentInventoryPosting', Locked = true;
        ConcurrentInventoryPosting: Boolean;
        ConcurrentInventoryPostingRead: Boolean;
        ConcurrentJobPostingLbl: Label 'ConcurrentJobPosting', Locked = true;
        ConcurrentJobPosting: Boolean;
        ConcurrentJobPostingRead: Boolean;
        ConcurrentResourcePostingLbl: Label 'ConcurrentResourcePosting', Locked = true;
        ConcurrentResourcePosting: Boolean;
        ConcurrentResourcePostingRead: Boolean;

#if not CLEAN24
    procedure IsPhysInvtOrderPackageTrackingEnabled(): Boolean
    begin
        exit(FeatureManagementFacade.IsEnabled(GetPhysInvtOrderPackageTrackingFeatureKey()));
    end;
#endif

#if not CLEAN24
    procedure IsGLCurrencyRevaluationEnabled(): Boolean
    begin
        exit(FeatureManagementFacade.IsEnabled(GetGLCurrencyRevaluationFeatureKey()));
    end;
#endif

    procedure IsAutomaticAccountCodesEnabled(): Boolean
    begin
        exit(FeatureManagementFacade.IsEnabled(GetAutomaticAccountCodesFeatureKey()));
    end;

    procedure IsSIEAuditFileExportEnabled(): Boolean
    begin
        exit(FeatureManagementFacade.IsEnabled(GetSIEAuditFileExportFeatureKeyId()));
    end;

    procedure IsConcurrentWarehousingPostingEnabled(): Boolean
    begin
        if not ConcurrentWarehousingPostingRead then
            ConcurrentWarehousingPosting := FeatureManagementFacade.IsEnabled(ConcurrentWarehousingPostingLbl);
        ConcurrentWarehousingPostingRead := true;
        exit(ConcurrentWarehousingPosting);
    end;

    procedure IsConcurrentInventoryPostingEnabled(): Boolean
    begin
        if not ConcurrentInventoryPostingRead then
            ConcurrentInventoryPosting := FeatureManagementFacade.IsEnabled(ConcurrentInventoryPostingLbl);
        ConcurrentInventoryPostingRead := true;
        exit(ConcurrentInventoryPosting);
    end;

    procedure IsConcurrentJobPostingEnabled(): Boolean
    begin
        if not ConcurrentJobPostingRead then
            ConcurrentJobPosting := FeatureManagementFacade.IsEnabled(ConcurrentJobPostingLbl);
        ConcurrentJobPostingRead := true;
        exit(ConcurrentJobPosting);
    end;

    procedure IsConcurrentResourcePostingEnabled(): Boolean
    begin
        if not ConcurrentResourcePostingRead then
            ConcurrentResourcePosting := FeatureManagementFacade.IsEnabled(ConcurrentResourcePostingLbl);
        ConcurrentResourcePostingRead := true;
        exit(ConcurrentResourcePosting);
    end;

#if not CLEAN26
    procedure IsManufacturingFlushingMethodActivateManualWithoutPickEnabled(): Boolean
    begin
        if MockEnabledManufacturingFlushingMethodActivateManualWithoutPick then
            exit(true);
        if not ManufacturingFlushingMethodActivateManualWithoutPickRead then begin
            ManufacturingFlushingMethodActivateManualWithoutPick := FeatureManagementFacade.IsEnabled(GetManufacturingFlushingMethodActivateManualWithoutPickFeatureKey());
            ManufacturingFlushingMethodActivateManualWithoutPickRead := true;
        end;
        exit(ManufacturingFlushingMethodActivateManualWithoutPick);
    end;

    local procedure GetManufacturingFlushingMethodActivateManualWithoutPickFeatureKey(): Text[50]
    begin
        exit(ManufacturingFlushingMethodActivateManualWithoutPickLbl);
    end;

    procedure SetMockEnabledManufacturingFlushingMethodActivateManualWithoutPick(SetMockEnabled: Boolean)
    begin
        MockEnabledManufacturingFlushingMethodActivateManualWithoutPick := SetMockEnabled;
    end;
#endif

#if not CLEAN24
    local procedure GetPhysInvtOrderPackageTrackingFeatureKey(): Text[50]
    begin
        exit(PhysInvtOrderPackageTrackingTxt);
    end;
#endif

#if not CLEAN24
    local procedure GetGLCurrencyRevaluationFeatureKey(): Text[50]
    begin
        exit(GLCurrencyRevaluationTxt);
    end;
#endif

    local procedure GetAutomaticAccountCodesFeatureKey(): Text[50]
    begin
        exit(AutomaticAccountCodesTxt);
    end;

    local procedure GetSIEAuditFileExportFeatureKeyId(): Text[50]
    begin
        exit(SIEAuditFileExportTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterFeatureEnableConfirmed', '', false, false)]
    local procedure HandleOnAfterFeatureEnableConfirmed(var FeatureKey: Record "Feature Key")
    begin
        // Log feature uptake
        case FeatureKey.ID of
#if not CLEAN24
            GLCurrencyRevaluationTxt:
                FeatureTelemetry.LogUptake('0000JRR', GLCurrencyRevaluationTxt, Enum::System.Telemetry."Feature Uptake Status"::Discovered);
#endif
#if not CLEAN26
            GetManufacturingFlushingMethodActivateManualWithoutPickFeatureKey():
                FeatureTelemetry.LogUptake('0000OQS', ManufacturingFlushingMethodActivateManualWithoutPickLbl, Enum::System.Telemetry."Feature Uptake Status"::Discovered);
#endif
            ConcurrentInventoryPostingLbl:
                FeatureTelemetry.LogUptake('0000OSN', ConcurrentInventoryPostingLbl, Enum::System.Telemetry."Feature Uptake Status"::Discovered);
            ConcurrentJobPostingLbl:
                FeatureTelemetry.LogUptake('0000OSO', ConcurrentJobPostingLbl, Enum::System.Telemetry."Feature Uptake Status"::Discovered);
            ConcurrentResourcePostingLbl:
                FeatureTelemetry.LogUptake('0000OSP', ConcurrentResourcePostingLbl, Enum::System.Telemetry."Feature Uptake Status"::Discovered);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterFeatureDisableConfirmed', '', false, false)]
    local procedure HandleOnAfterFeatureDisableConfirmed(FeatureKey: Record "Feature Key")
    begin
        // Log feature
        case FeatureKey.ID of
            ConcurrentInventoryPostingLbl:
                FeatureTelemetry.LogUptake('0000OSQ', ConcurrentInventoryPostingLbl, Enum::System.Telemetry."Feature Uptake Status"::Undiscovered);
            ConcurrentJobPostingLbl:
                FeatureTelemetry.LogUptake('0000OSR', ConcurrentJobPostingLbl, Enum::System.Telemetry."Feature Uptake Status"::Undiscovered);
            ConcurrentResourcePostingLbl:
                FeatureTelemetry.LogUptake('0000OSS', ConcurrentResourcePostingLbl, Enum::System.Telemetry."Feature Uptake Status"::Undiscovered);
        end;
    end;

#if not CLEAN25
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterUpdateData', '', false, false)]
    local procedure HandleOnAfterUpdateData(var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        FeatureTelemetry: Codeunit System.Telemetry."Feature Telemetry";
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        // Log feature uptake
        if FeatureDataUpdateStatus."Feature Status" <> FeatureDataUpdateStatus."Feature Status"::Complete then
            exit;
        case FeatureDataUpdateStatus."Feature Key" of
            PriceCalculationMgt.GetFeatureKey():
                FeatureTelemetry.LogUptake('0000LLR', PriceCalculationMgt.GetFeatureTelemetryName(), Enum::System.Telemetry."Feature Uptake Status"::Discovered);
        end;
    end;
#endif
}
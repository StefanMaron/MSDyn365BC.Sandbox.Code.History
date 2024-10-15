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
        AutomaticAccountCodesTxt: Label 'AutomaticAccountCodes', Locked = true;
        SIEAuditFileExportTxt: label 'SIEAuditFileExport', Locked = true;
#if not CLEAN24
        PhysInvtOrderPackageTrackingTxt: Label 'PhysInvtOrderPackageTracking', Locked = true;
#endif
#if not CLEAN24
        GLCurrencyRevaluationTxt: Label 'GLCurrencyRevaluation', Locked = true;
#endif
        ConcurrentWarehousingPostingLbl: Label 'ConcurrentWarehousingPosting', Locked = true;
        ConcurrentWarehousingPosting: Boolean;
        ConcurrentWarehousingPostingRead: Boolean;

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
#if not CLEAN24
    var
        FeatureTelemetry: Codeunit System.Telemetry."Feature Telemetry";
#endif
    begin
#if not CLEAN24
        // Log feature uptake
        case FeatureKey.ID of
            GLCurrencyRevaluationTxt:
                FeatureTelemetry.LogUptake('0000JRR', GLCurrencyRevaluationTxt, Enum::System.Telemetry."Feature Uptake Status"::Discovered);
        end;
#endif
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
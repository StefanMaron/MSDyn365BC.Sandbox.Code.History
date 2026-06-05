/*! Copyright (C) Microsoft Corporation. All rights reserved. */
"use strict";

/*!-----------------------------------------------------------------------------------------------------------
|    This addin uses the PowerBI SDK to create an embedded experience of Power BI within Business Central.   |
|    Package: https://github.com/microsoft/PowerBI-JavaScript                                                |
|    Docs:    https://docs.microsoft.com/en-us/javascript/api/powerbi/powerbi-client/                        |
------------------------------------------------------------------------------------------------------------*/

var embed = null;
var activePage = null;
var legacySettingsObject = null;
var models = null;
var pbiAuthToken = null;
// Settings:
var _showBookmarkSelection = false;
var _showFilters = false;
var _showPageSelection = false;
var _showZoomBar = false;
var _forceTransparentBackground = false;
var _forceFitToPage = false;
var _addBottomPadding = false;
var _localeSettings = {};

function Initialize() {
    models = window['powerbi-client'].models;

    RaiseAddInReady();
}

// Addin Callbacks

function RaiseAddInReady() {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddInReady', null);
}

function RaiseErrorOccurred(operation, errorMessage) {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ErrorOccurred', [operation, errorMessage]);
}

function RaiseReportPageChanged(newpagename, newpagefilters) {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ReportPageChanged', [newpagename, newpagefilters]);
}

function RaiseReportLoaded(reportfilters, activepagename, activepagefilters, correlationId) {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ReportLoaded', [reportfilters, activepagename, activepagefilters, correlationId]);
}

function RaiseDashboardLoaded(correlationId) {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('DashboardLoaded', [correlationId]);
}

function RaiseDashboardTileLoaded(correlationId) {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('DashboardTileLoaded', [correlationId]);
}

function RaiseReportVisualLoaded(correlationId) {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ReportVisualLoaded', [correlationId]);
}

// Obsolete Functions

function InitializeReport(reportLink, reportId, authToken, powerBIEnv) {
    // OBSOLETE
    EmbedReport(reportLink, reportId, authToken, '');
}

function EmbedReportWithOptions(reportLink, reportId, authToken, pageName, showPanes) {
    // OBSOLETE
    EmbedReport(reportLink, reportId, authToken, pageName)
}

function EmbedReport(reportLink, reportId, authToken, pageName) {
    // OBSOLETE
    pbiAuthToken = authToken;
    EmbedPowerBIReport(reportLink, reportId, pageName);
}

function EmbedDashboard(dashboardLink, dashboardId, authToken) {
    // OBSOLETE
    pbiAuthToken = authToken;
    EmbedPowerBIDashboard(dashboardLink, dashboardId);
}

function EmbedDashboardTile(dashboardTileLink, dashboardId, tileId, authToken) {
    // OBSOLETE
    pbiAuthToken = authToken;
    EmbedPowerBIDashboardTile(dashboardTileLink, dashboardId, tileId);
}

function EmbedReportVisual(reportVisualLink, reportId, pageName, visualName, authToken) {
    // OBSOLETE
    pbiAuthToken = authToken;
    EmbedPowerBIReportVisual(reportVisualLink, reportId, pageName, visualName);
}

function ViewMode() {
    // OBSOLETE
    embed.switchMode('View').catch(function (error) {
        ProcessError('ViewMode', error);
    });
}

function EditMode() {
    // OBSOLETE
    embed.switchMode('Edit').catch(function (error) {
        ProcessError('EditMode', error);
    });
}

function InitializeFrame(fullpage, ratio) {
    // OBSOLETE
    legacySettingsObject = {
        panes: {
            bookmarks: {
                visible: false
            },
            fields: {
                visible: fullpage,
                expanded: false
            },
            filters: {
                visible: fullpage,
                expanded: fullpage
            },
            pageNavigation: {
                visible: fullpage
            },
            selection: {
                visible: fullpage
            },
            syncSlicers: {
                visible: fullpage
            },
            visualizations: {
                visible: fullpage,
                expanded: false
            }
        },

        background: models.BackgroundType.Transparent,

        layoutType: models.LayoutType.Custom,
        customLayout: {
            displayOption: models.DisplayOption.FitToPage
        }
    }
}

// Exposed Functions

function EmbedPowerBIReport(reportLink, reportId, pageName) {
    ClearEmbedGlobals();
    ValidatePowerBIHost(reportLink);

    var embedConfiguration = InitializeEmbedConfig();
    embedConfiguration.type = 'report';
    embedConfiguration.id = SanitizeId(reportId);
    embedConfiguration.embedUrl = reportLink;
    if (pageName && (pageName != '')) {
        embedConfiguration.pageName = pageName;
    }
    DisplayEmbed(embedConfiguration);

    RegisterCommonEmbedEvents();

    embed.off("rendered");
    embed.on('rendered', function (event) {
        var reportPages = null;
        var reportFilters = null;
        var pageFilters = null;
        var embedCorrelationId = null;

        var promises =
            [
                embed.getCorrelationId().then(function (correlationId) {
                    embedCorrelationId = correlationId;
                }),

                embed.getPages().then(function (pages) {
                    var pagesArray = pages.reduce(ReduceByNameFunction, []);
                    reportPages = JSON.stringify(pagesArray);
                }),

                embed.getFilters().then(function (filters) {
                    reportFilters = JSON.stringify(filters);
                }),

                embed.getActivePage().then(function (page) {
                    activePage = page;
                    return page.getFilters().then(function (filters) {
                        pageFilters = JSON.stringify(filters);
                    });
                })
            ]

        Promise.all(promises).then(
            function (values) {
                embed.off("rendered");
                RaiseReportLoaded(reportFilters, reportPages, pageFilters, embedCorrelationId);
            },
            function (error) {
                ProcessError('LoadReportDetails', error);
            });
    });

    embed.off("pageChanged");
    embed.on('pageChanged', function (event) {
        activePage = event.detail.newPage;
        activePage.getFilters().then(function (filters) {
            RaiseReportPageChanged(activePage.name, JSON.stringify(filters));
        },
            function (error) {
                ProcessError('LoadPageFilters', error);
            });
    });
}

function EmbedPowerBIDashboard(dashboardLink, dashboardId) {
    ClearEmbedGlobals();
    ValidatePowerBIHost(dashboardLink);

    var embedConfiguration = InitializeEmbedConfig();
    embedConfiguration.type = 'dashboard';
    embedConfiguration.id = SanitizeId(dashboardId);
    embedConfiguration.embedUrl = dashboardLink;
    DisplayEmbed(embedConfiguration);

    RegisterCommonEmbedEvents();

    embed.off("loaded");
    embed.on('loaded', function (event) {
        embed.getCorrelationId().then(function (correlationId) {
            RaiseDashboardLoaded(correlationId);
        },
            function (error) {
                ProcessError('LoadDashboardCorrelationId', error);
            });
    });
}

function EmbedPowerBIDashboardTile(dashboardTileLink, dashboardId, tileId) {
    ClearEmbedGlobals();
    ValidatePowerBIHost(dashboardTileLink);

    var embedConfiguration = InitializeEmbedConfig();
    embedConfiguration.type = 'tile';
    embedConfiguration.id = SanitizeId(tileId);
    embedConfiguration.dashboardId = SanitizeId(dashboardId);
    embedConfiguration.embedUrl = dashboardTileLink;
    DisplayEmbed(embedConfiguration);

    RegisterCommonEmbedEvents();

    embed.off("loaded");
    embed.on('loaded', function (event) {
        embed.getCorrelationId().then(function (correlationId) {
            RaiseDashboardTileLoaded(correlationId);
        },
            function (error) {
                ProcessError('LoadDashboardTileCorrelationId', error);
            });
    });
}

function EmbedPowerBIReportVisual(reportVisualLink, reportId, pageName, visualName) {
    ClearEmbedGlobals();
    ValidatePowerBIHost(reportVisualLink);

    var embedConfiguration = InitializeEmbedConfig();
    embedConfiguration.type = 'visual';
    embedConfiguration.id = SanitizeId(reportId);
    embedConfiguration.pageName = SanitizeId(pageName);
    embedConfiguration.visualName = SanitizeId(visualName);
    embedConfiguration.embedUrl = reportVisualLink;
    DisplayEmbed(embedConfiguration);

    RegisterCommonEmbedEvents();

    embed.off("loaded");
    embed.on('loaded', function (event) {
        embed.getCorrelationId().then(function (correlationId) {
            RaiseReportVisualLoaded(correlationId);
        },
            function (error) {
                ProcessError('LoadReportVisualCorrelationId', error);
            });
    });
}

function FullScreen() {
    embed.fullscreen();
}

function UpdateReportFilters(filters) {
    var newFilters = null;
    try {
        newFilters = JSON.parse(filters);
    } catch (err) {
        ProcessError('ParseReportFilters', err);
    }

    embed.updateFilters(models.FiltersOperations.Replace, newFilters).catch(function (error) {
        ProcessError('UpdateReportFilters', error);
    });
}

function RemoveReportFilters() {
    embed.removeFilters().catch(function (error) {
        ProcessError('RemoveReportFilters', error);
    });
}

function UpdatePageFilters(filters) {
    var newFilters = null;
    try {
        newFilters = JSON.parse(filters);
    } catch (err) {
        ProcessError('ParsePageFilters', err);
    }

    activePage.updateFilters(models.FiltersOperations.Replace, newFilters).catch(function (error) {
        ProcessError('UpdatePageFilters', error);
    });
}

function RemovePageFilters() {
    activePage.removeFilters().catch(function (error) {
        ProcessError('RemovePageFilters', error);
    });
}

function SetPage(pageName) {
    report.setPage(pageName).catch(function (error) {
        ProcessError('SetPage', error);
    });
}

function SetLocale(newLocale) {
    _localeSettings = {
        language: newLocale
    }
}

function SetToken(authToken) {
    pbiAuthToken = authToken;
}

function SetSettings(showBookmarkSelection, showFilters, showPageSelection, showZoomBar, forceTransparentBackground, forceFitToPage, addBottomPadding) {
    _showBookmarkSelection = showBookmarkSelection;
    _showFilters = showFilters;
    _showPageSelection = showPageSelection;
    _showZoomBar = showZoomBar;
    _forceTransparentBackground = forceTransparentBackground;
    _forceFitToPage = forceFitToPage;
    _addBottomPadding = addBottomPadding;
}

// Internal functions

function CompileSettings() {
    if (legacySettingsObject) {
        // Already initialized. This case is only used for backwards compatibility.
        return legacySettingsObject;
    }

    if (_addBottomPadding) {
        var iframe = window.frameElement;
        iframe.style.paddingBottom = '42px';
    }
    else {
        var iframe = window.frameElement;
        iframe.style.removeProperty('paddingBottom');
    }

    var settingsObject = {
        panes: {
            bookmarks: {
                visible: _showBookmarkSelection
            },
            filters: {
                visible: _showFilters,
                expanded: false
            },
            pageNavigation: {
                visible: _showPageSelection
            },
            fields: { // In edit mode, allows selecting fields to add to the report
                visible: false
            },
            selection: { // In edit mode, allows selecting visuals from a list instead of clicking in the UI
                visible: false
            },
            syncSlicers: { // In edit mode, allows syncing slicers through pages
                visible: false
            },
            visualizations: { // In edit mode, allows adding new visualizations
                visible: false
            }
        },

        bars: {
            statusBar: {
                visible: _showZoomBar
            }
        },

        localeSettings: _localeSettings
    }

    if (_forceTransparentBackground) {
        settingsObject.background = models.BackgroundType.Transparent;
    }

    if (_forceFitToPage) {
        settingsObject.layoutType = models.LayoutType.Custom;
        settingsObject.customLayout = {
            displayOption: models.DisplayOption.FitToPage
        }
    }

    return settingsObject;
}

function ExtractBootstrapConfiguration(embedConfiguration) {
    return {
        type: embedConfiguration.type,
        hostname: GetHost(embedConfiguration.embedUrl),
        settings: {
            localeSettings: embedConfiguration.settings.localeSettings
        }
    };
}

function ClearEmbedGlobals() {
    embed = null;
    activePage = null;
}

function InitializeEmbedConfig() {
    if (!pbiAuthToken || (pbiAuthToken == '')) {
        RaiseErrorOccurred('Initialize Config', 'No token was provided');
    }

    var embedConfiguration = {
        tokenType: models.TokenType.Aad,
        accessToken: pbiAuthToken,

        viewMode: models.ViewMode.View,
        permissions: models.Permissions.All,
        settings: CompileSettings()
    };

    return embedConfiguration;
}

function DisplayEmbed(embedConfiguration) {
    var reportContainer = document.getElementById('controlAddIn');

    powerbi.reset(reportContainer);


    // NOTE: Bootstrap is here to work around an issue with how the powerbi.js library handles ScoreCards.
    // ScoreCards are classified as Reports, but have different URL structure. If we call powerbi.embed directly on a ScoreCard, the library
    // tries to load non-existing ScoreCard resources. Bootstrapping without the final URL forces the library to load the correct Report resources.
    var bootstrapConfiguration = ExtractBootstrapConfiguration(embedConfiguration);
    powerbi.bootstrap(reportContainer, bootstrapConfiguration);

    embed = powerbi.embed(reportContainer, embedConfiguration);
}

function RegisterCommonEmbedEvents() {
    embed.off("error");
    embed.on("error", function (event) {
        ProcessError('OnError', event);
    });
}

function ReduceByNameFunction(accumulator, current) {
    accumulator.push(current.name);
    return accumulator;
}

function SanitizeId(id) {
    // From: {79a5e047-a665-4c83-900b-f5ccf19e01c7}
    // To:    79a5e047-a665-4c83-900b-f5ccf19e01c7
    return id.replace(/[{}]/g, "");
}

function GetHost(url) {
    var urlObject = new URL(url);
    return urlObject.protocol.concat('//').concat(urlObject.host)
}

function ProcessError(operation, error) {
    LogErrorToConsole(operation, error);

    var errorMessage = GetErrorMessage(error);
    RaiseErrorOccurred(operation, errorMessage);
}

function LogErrorToConsole(operation, error) {
    console.error('Error occurred (' + operation + '). See the detailed error in the following message.');
    console.error(error);
}

function GetErrorMessage(error) {
    if (error && error.message) {
        return error.message;
    }

    if (error && error.detail && error.detail.message) {
        return error.detail.message;
    }

    return error.toString();
}

function ValidatePowerBIHost(embedUrl) {
    var urlHost = GetHost(embedUrl);
    if (!urlHost.endsWith(".powerbi.com") && !urlHost.endsWith('.analysis-df.windows.net')) {
        var errorMsg = 'The host "' + urlHost + '" is not a valid Power BI host.';
        ProcessError('InvalidHost', errorMsg);
        throw new Error(errorMsg);
    }
}

// SIG // Begin signature block
// SIG // MIInbAYJKoZIhvcNAQcCoIInXTCCJ1kCAQExDzANBglg
// SIG // hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
// SIG // BgEEAYI3AgEeMCQCAQEEEBDgyQbOONQRoqMAEEvTUJAC
// SIG // AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
// SIG // Qxmqr8k/PHcHFvhwYGO6l4suUHuC/SdNsP9xK4vp0YWg
// SIG // ggzJMIIGBDCCA+ygAwIBAgITMwAAAhz6zcWb6C9+xAAA
// SIG // AAACHDANBgkqhkiG9w0BAQsFADBXMQswCQYDVQQGEwJV
// SIG // UzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5n
// SIG // IFBDQSAyMDI0MB4XDTI2MDQxNjE4NTk0MVoXDTI3MDQx
// SIG // NTE4NTk0MVowdDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
// SIG // Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
// SIG // BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEeMBwG
// SIG // A1UEAxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMIIBIjAN
// SIG // BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1bGX4Dip
// SIG // jN9Rz36FjqDRIsNEpQoiMVDAtCPTTFm7nCjsP3vZT6AK
// SIG // HoUFbukhuuVeBD862LJwZxTzaIuPx6DnY4c9apKxLeCO
// SIG // rRHMV1OqDnmPcxr3gv94gXroS2MTNzPz5HFKHmxfjXnZ
// SIG // 5vDpHUj6A7vIplYhz0Kv/AkFLtFkUeKxPnTEX66Van5j
// SIG // Ytqlgl/eE+DLHqYoxlZMBP/7SYNK8gImHR09+C0p5Rv0
// SIG // UgWZkERlmeYPI6pyo0T2q0qjH7dYL47lE1YLVjWX4HCx
// SIG // UiuVmtJsq6vDj3IExhrEYLp/rZ0kviMQ08VbADx9Ts7z
// SIG // 48KJoLgcoVHvznL1DdA+Vpqe8QIDAQABo4IBqjCCAaYw
// SIG // DgYDVR0PAQH/BAQDAgeAMB8GA1UdJQQYMBYGCisGAQQB
// SIG // gjdMCAEGCCsGAQUFBwMDMB0GA1UdDgQWBBTaB+2tmA4z
// SIG // ksKZKegx3JlEuyftMjBUBgNVHREETTBLpEkwRzEtMCsG
// SIG // A1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9u
// SIG // cyBMaW1pdGVkMRYwFAYDVQQFEw0yMzAwMTIrNTA3NTY5
// SIG // MB8GA1UdIwQYMBaAFH9ZP1Qh2q1P7wXl5qPXLQaUEggx
// SIG // MGAGA1UdHwRZMFcwVaBToFGGT2h0dHA6Ly93d3cubWlj
// SIG // cm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
// SIG // MENvZGUlMjBTaWduaW5nJTIwUENBJTIwMjAyNC5jcmww
// SIG // bQYIKwYBBQUHAQEEYTBfMF0GCCsGAQUFBzAChlFodHRw
// SIG // Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRz
// SIG // L01pY3Jvc29mdCUyMENvZGUlMjBTaWduaW5nJTIwUENB
// SIG // JTIwMjAyNC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG
// SIG // 9w0BAQsFAAOCAgEAFJxKoWkV3tE94SCY73UBKxJKwP+2
// SIG // wco5+reSAKzg5JEY85GMLSjHNsmI9qrmjay7rVsNmGXJ
// SIG // 4Cj8tW+9WMgyUE8uDQ0cGkofU8ObYa5NzZnD6wB4mub7
// SIG // XASdQoLSiu5kGyHENtnfzd/Nd2sggwxXsLtfo7GZl/q/
// SIG // 2kxKmjjOE1cVbUUpLgsvJwFyrgoTii4v8wOF7h/IhGKi
// SIG // LI9mKDWnksVZnhohEV6SnaN3Q5mItJDucNg/FUuHN/vY
// SIG // eoBJWAWgAIP3WBKwYNu6k9779M0QyYSbn7wjcpQPEu//
// SIG // vB+RPz1eXJ4Op2vVVf8PTld6rrjQ+s3RmthF9/BpaedB
// SIG // fQCEJN6dsV5nL6Kw3jOFye1JVmAYuoPNCdUkjkJyJwmB
// SIG // RJrH1DZ9/tQGkySkiS/N6rigK02nNqSobtGM88686Oh6
// SIG // 7EYkCs6Z0QW9f3TGuj94c++V2zEQXLTbBYWQtO1gpoxM
// SIG // XS4Nnh1ubldE2PA+fusKMyX+7xd/lh5GDzvOWfgQulOB
// SIG // ZDW2DcnGfXBOI9bV0Xcgwn5penNB1jx4zVQzm67/ZSrd
// SIG // 6lKhaV9/FQqlQsjTjtVHF30IlYycN9lNllCmY7f53iSh
// SIG // xAbJvZBbC7ls5EOd/qnGkmsrZrAp5NoDoJa5Q+Xd5Csr
// SIG // 7wMPq85tJU/Ct/D+jy8X2UB4buFvHVewL/DdmZgwgga9
// SIG // MIIEpaADAgECAhMzAAAAOTu2Nxm/Bh1nAAAAAAA5MA0G
// SIG // CSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEG
// SIG // A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
// SIG // ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZp
// SIG // Y2F0ZSBBdXRob3JpdHkgMjAxMTAeFw0yNDA4MDgyMDU0
// SIG // MThaFw0zNjAzMjIyMjEzMDRaMFcxCzAJBgNVBAYTAlVT
// SIG // MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
// SIG // KDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25pbmcg
// SIG // UENBIDIwMjQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
// SIG // ggIKAoICAQDYAZwe4zjHqpUWBzWtuub+CGPXx/EyoXph
// SIG // 3zyDXtYKS2ld3YYN9uFsB9Oi3B26Z7AbpAgzYra8qNHb
// SIG // UvxFuiP8hC/2y0mPISqW30LlrrAT6/ams2HA8Qlv6p42
// SIG // +SbCNbPGzToN21QE70FS+LXH9N2k8nLM/EHgnTNJf8h0
// SIG // TmyfUKmszNa+lTxDieyy/rhBG+98OkArobPPWtbr9c3q
// SIG // zmDJ7J3kUcAm6cltdSHIIFNHESgw6taY1ScyGyBevqIl
// SIG // 120XjrIHiPM7tRckHytH1ZGsmvEplR0P7Tn9t5meFvZN
// SIG // EYttkFvad1IEguTlA5LSscXAphi+rVy3zhklhyCFeGK0
// SIG // yU0+jzbcuURKIxybmRwK5BfVZx0xEVqE4wM3yN5D/uW+
// SIG // GpVHYYAGe7bTrtW1Z13x2qj2Jdqz7NtI4tNyzlVrIf62
// SIG // nYBNe3rOYS/repVdHlR61YbLLETlibs9jFzAre4sO5RT
// SIG // xvS1yho7JqJ59oKLRnRyLhIOSZyTCVZosXeS0ZZJoGEW
// SIG // Ss4cUgsMqBiKtD4WgO2PlT3LeaQh5Io3CCA5tJ5ZCvtC
// SIG // snqaJXKhptE/xmEETIRyZRjjplUKKd+sFFVGJJVMvvrw
// SIG // 1nhIBKOLO4cTepiG39jEiEP4iHzGYCcQuvaLpDFFwqzg
// SIG // t0pBP8SJIKX5dtjDNYrZGd+ZzV5DKJVNZQIDAQABo4IB
// SIG // TjCCAUowDgYDVR0PAQH/BAQDAgGGMBAGCSsGAQQBgjcV
// SIG // AQQDAgEAMB0GA1UdDgQWBBR/WT9UIdqtT+8F5eaj1y0G
// SIG // lBIIMTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAP
// SIG // BgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIx
// SIG // kEO5FAVO4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuG
// SIG // SWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3Js
// SIG // L3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8w
// SIG // M18yMi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUF
// SIG // BzAChkJodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
// SIG // L2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
// SIG // Mi5jcnQwDQYJKoZIhvcNAQEMBQADggIBABSUHzgoT+6J
// SIG // 5+nyyDCq0pTdVmCsAxYAHXcpjlDtxazPHewf1v4kOg8V
// SIG // 7A5+w+VuMDMGHi8rLXBKn5I8+DVEUYGs8jLuckc0IeC6
// SIG // owOLUrU3CYdaKRMaO55+T7jwWJ27tPkx0rlR03tFU0z1
// SIG // YYpcv6Yhaw6N2sUPT+AvjpecnrftoE33pCAkucUvnGH0
// SIG // iL4J9CZLFQVTGFSOUBbv6oZy4bBBRFMxvH779IY4JDvp
// SIG // ZKVfbcuhpDeL3Z3e8mukOmkfct+GojNapsWsQYujlJ8j
// SIG // Zen5Lrp/3YkxZ2Ay06aTpK/5oOVknwog1TDQsbY+MDyg
// SIG // uTph5tQ0CLfzDaJG2x91BrBT9UG87C6HLkqiwrx9PSKN
// SIG // 3wz05rHEfWO+RuKl+0U1/AHQT6NCOjhKI39/c7hWbdKj
// SIG // h5uuWFkBOvXGTNrnhNTAdOXTTYByvYExO8yryv34PAdq
// SIG // o1vPDE/1heVebr2RramvRUi9kWswKwPqwz7n+iRmM+B6
// SIG // YDGRweEurM1kimAb9FYrAs38YHlPnarl1vW3dGrmJTge
// SIG // fAz3DmCnXN0nveIPsS+KXBIWweeCToAJMGE7v/XS3h9q
// SIG // Q6niWQAAVQ1kUAml3zuS4MisCgi2F6YoK2WAo1EgXK/l
// SIG // XvDxVjIVU0JdL+KvCfwFJkDeVuJ9dNXGNi+AOxk0BtYd
// SIG // 9hxwL30BElj9MYIZ+zCCGfcCAQEwbjBXMQswCQYDVQQG
// SIG // EwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
// SIG // aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBTaWdu
// SIG // aW5nIFBDQSAyMDI0AhMzAAACHPrNxZvoL37EAAAAAAIc
// SIG // MA0GCWCGSAFlAwQCAQUAoIGuMBkGCSqGSIb3DQEJAzEM
// SIG // BgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgor
// SIG // BgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEiBCAIlpu3yDBM
// SIG // McdIn+DndQDgcPCyuG6Mk2nesUhcOsji+TBCBgorBgEE
// SIG // AYI3AgEMMTQwMqAUgBIATQBpAGMAcgBvAHMAbwBmAHSh
// SIG // GoAYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tMA0GCSqG
// SIG // SIb3DQEBAQUABIIBALEThU87C/mGqDDtuycE1RW6YQkF
// SIG // nHp1m+v1ZGs08Bl/qpnLy4LxxXJe2mBFm3p9buItLs7P
// SIG // +ZS3udyCE3K/QZgUbYYwY2eXmvMnC1aTjV1aQf+BYtrc
// SIG // M2eRiNAMAx77tGffpIiP5XufDmyi4WkLhiNReKG/Yd57
// SIG // St2mPPb9Rl1bOBwPSUX22fNBtNMVC159AhRZW5cvzb97
// SIG // PXLpY6M4qhBJ6hat7CXu9W10/JWIzqyj3mgpEI5ok8Fs
// SIG // JldGxLLHty8y5kUJi7TWoVLPiTF2SXST9nDxF487rYFm
// SIG // gCWx6IizzsGOl6mPKB4CrKtJ4o2i0xID1ajvc7s9uSf+
// SIG // fsU96EmhghetMIIXqQYKKwYBBAGCNwMDATGCF5kwgheV
// SIG // BgkqhkiG9w0BBwKggheGMIIXggIBAzEPMA0GCWCGSAFl
// SIG // AwQCAQUAMIIBWgYLKoZIhvcNAQkQAQSgggFJBIIBRTCC
// SIG // AUECAQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEF
// SIG // AAQg4QXMN5GOve8pA+F8IXvuh/aNvywFE9b/sGCVEgQi
// SIG // W9QCBmoQlJkbJhgTMjAyNjA2MDMxOTAyMTkuMjg2WjAE
// SIG // gAIB9KCB2aSB1jCB0zELMAkGA1UEBhMCVVMxEzARBgNV
// SIG // BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
// SIG // HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEt
// SIG // MCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0
// SIG // aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hpZWxkIFRT
// SIG // UyBFU046MkQxQS0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1p
// SIG // Y3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WgghH7MIIH
// SIG // KDCCBRCgAwIBAgITMwAAAhLRCAY8yhhPqgABAAACEjAN
// SIG // BgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEG
// SIG // A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
// SIG // ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
// SIG // Q0EgMjAxMDAeFw0yNTA4MTQxODQ4MTVaFw0yNjExMTMx
// SIG // ODQ4MTVaMIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
// SIG // V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
// SIG // A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYD
// SIG // VQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25z
// SIG // IExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVT
// SIG // TjoyRDFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
// SIG // b2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCAiIwDQYJKoZI
// SIG // hvcNAQEBBQADggIPADCCAgoCggIBAK9M06A5KVkLbGXp
// SIG // EtHFdKrg3SkkxpKL7wWmR9DgCBItDtwnDu+yYl/HOBKa
// SIG // vbomx1WWdVvy6LnxNe9r5EVzvkGDbVlqKxAidgHGUNdG
// SIG // 6QJbZIWTYl5VSfC90M4SoK165jJJtifv4PNVNtyT3DuM
// SIG // FxxH7aJ098KXf//d+q45sMTJuzZG7MoGyX/uAFQTDa+G
// SIG // jD0IQXe+qHdCjAelq78hBjjlNPPdzhbn0uRA3suJ+OFo
// SIG // GsSRNFZ79/zjr7jsOSqdSj6o42Cfi/csC7gTLXA3y6TU
// SIG // Dv4dXhRKDK24hDOu0znzZV38Ww8+DJbGLy4qMYHdl83s
// SIG // tUMa1dfoviclQyTIknvYCjrs6YkEBRNfQ1D4LIncoy08
// SIG // 1xIUlSwZUaK9HglX+4AukX5PDWN6ztrIIDi+/b1ORbgy
// SIG // k4f7CDrXFB3hwuNowRgfrX3SgtSjgUflJTfWjs4PJqVD
// SIG // SNhYKkL4q1T/aaW3jFH76dsAPb6Mk4kVrw4MwsaPMZSd
// SIG // Z7HGExyEK5pBfY/wmtCA5rfH7zp+uJ55SThlGGWBzAtZ
// SIG // dMbYJGExNRElKqpGsCpO4qm8XZy8snEvnUfs2sT7nTAy
// SIG // 60Bc/JYH8vaG5NA/Bwtnc4VqWDZ+YXZKDxM4AqkFDqfL
// SIG // 90I/7HeGp8rqXuSqApIwATj98oUkOFvWfg6yZ4TP627F
// SIG // wu6E79unAgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQUUgW5
// SIG // UsW+XGCmDsL3f1X6Fzn7t94wHwYDVR0jBBgwFoAUn6cV
// SIG // XQBeYl2D9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKg
// SIG // UIZOaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
// SIG // cy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBD
// SIG // QSUyMDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBc
// SIG // BggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQu
// SIG // Y29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1l
// SIG // LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0T
// SIG // AQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
// SIG // BgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQADggIB
// SIG // AF50gJJl+/UXO5cUtcDqM1ye1dKLuQ57VXDiaZSJA47x
// SIG // DfASEKYeFPoEji2blUXj/8/WHVIlJHD8C9TzNuOf5BF9
// SIG // RHoKcTXPBwwOoSgh4NACzRHLsZxjpYCi6JF31Hq9Q+YY
// SIG // lvDwATPUfp3orXk4D2mkZSRbxk2L6LXNLqhohEuYTEIS
// SIG // /ETRYaUvUXCFh7Z0BhJ63TlLwgIbOBXlYmsHJi0yr/tf
// SIG // O9HPzHkx4tEA3Xkfu/1oOKoZCdpNYhByXZmH/KyFdDUQ
// SIG // WXHUU03R3nt+Ulz+Z3jQnwJIwyLmcnEbneo8zywjS4jW
// SIG // MxlwbMMycoI+BHkjkU+8DL2hbinkQF6Fwt8MGL4CLCNc
// SIG // 59wxmOtuWPsmUovFDUjR7q4t+mb/WvkOLycA6WCt+ktE
// SIG // wdqX+8S4oh99p5O2Cu90YPfFun2diDbs2M2exoYL3335
// SIG // I+BFF4NRNBH32NaRKpG6Q0z+4fwwarc6D17MsNjFIfu8
// SIG // r1nKtgRmUrnGugmOl+IqDLnOT1qbJrzjpYuwETQOwG/J
// SIG // CnQnNoDQy2nIJbMHmRHPf1UAeoZbP2+ipN9p5MLhxMSp
// SIG // WnqElaygeVPcZadfnPCf+xiY+EcOwIkPLXKflpn8g/Cs
// SIG // V9kJSmw4uElI54Jb+Ote0fPmv3A1icmjLfNu/Vp+39sj
// SIG // HnTe5HxiEOUmY+ukXYXZWTqvMIIHcTCCBVmgAwIBAgIT
// SIG // MwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG9w0BAQsF
// SIG // ADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
// SIG // bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
// SIG // FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMp
// SIG // TWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9y
// SIG // aXR5IDIwMTAwHhcNMjEwOTMwMTgyMjI1WhcNMzAwOTMw
// SIG // MTgzMjI1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
// SIG // V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
// SIG // A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
// SIG // VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
// SIG // MDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
// SIG // AOThpkzntHIhC3miy9ckeb0O1YLT/e6cBwfSqWxOdcjK
// SIG // NVf2AX9sSuDivbk+F2Az/1xPx2b3lVNxWuJ+Slr+uDZn
// SIG // hUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V29YZQ
// SIG // 3MFEyHFcUTE3oAo4bo3t1w/YJlN8OWECesSq/XJprx2r
// SIG // rPY2vjUmZNqYO7oaezOtgFt+jBAcnVL+tuhiJdxqD89d
// SIG // 9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkNyjYtcI4x
// SIG // yDUoveO0hyTD4MmPfrVUj9z6BVWYbWg7mka97aSueik3
// SIG // rMvrg0XnRm7KMtXAhjBcTyziYrLNueKNiOSWrAFKu75x
// SIG // qRdbZ2De+JKRHh09/SDPc31BmkZ1zcRfNN0Sidb9pSB9
// SIG // fvzZnkXftnIv231fgLrbqn427DZM9ituqBJR6L8FA6PR
// SIG // c6ZNN3SUHDSCD/AQ8rdHGO2n6Jl8P0zbr17C89XYcz1D
// SIG // TsEzOUyOArxCaC4Q6oRRRuLRvWoYWmEBc8pnol7XKHYC
// SIG // 4jMYctenIPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTY
// SIG // uVD5C4lh8zYGNRiER9vcG9H9stQcxWv2XFJRXRLbJbqv
// SIG // UAV6bMURHXLvjflSxIUXk8A8FdsaN8cIFRg/eKtFtvUe
// SIG // h17aj54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TAS
// SIG // BgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQW
// SIG // BBQqp1L+ZMSavoKRPEY1Kc8Q/y8E7jAdBgNVHQ4EFgQU
// SIG // n6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUwUzBR
// SIG // BgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0
// SIG // cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2Nz
// SIG // L1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoGCCsGAQUF
// SIG // BwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsG
// SIG // A1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1Ud
// SIG // IwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1Ud
// SIG // HwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0
// SIG // LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1
// SIG // dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEww
// SIG // SgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0
// SIG // LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAt
// SIG // MDYtMjMuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCdVX38
// SIG // Kq3hLB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEz
// SIG // tTnXwnE2P9pkbHzQdTltuw8x5MKP+2zRoZQYIu7pZmc6
// SIG // U03dmLq2HnjYNi6cqYJWAAOwBb6J6Gngugnue99qb74p
// SIG // y27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G82jf
// SIG // ZfakVqr3lbYoVSfQJL1AoL8ZthISEV09J+BAljis9/kp
// SIG // icO8F7BUhUKz/AyeixmJ5/ALaoHCgRlCGVJ1ijbCHcNh
// SIG // cy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI95ko+ZjtP
// SIG // u4b6MhrZlvSP9pEB9s7GdP32THJvEKt1MMU0sHrYUP4K
// SIG // WN1APMdUbZ1jdEgssU5HLcEUBHG/ZPkkvnNtyo4JvbMB
// SIG // V0lUZNlz138eW0QBjloZkWsNn6Qo3GcZKCS6OEuabvsh
// SIG // VGtqRRFHqfG3rsjoiV5PndLQTHa1V1QJsWkBRH58oWFs
// SIG // c/4Ku+xBZj1p/cvBQUl+fpO+y/g75LcVv7TOPqUxUYS8
// SIG // vwLBgqJ7Fx0ViY1w/ue10CgaiQuPNtq6TPmb/wrpNPgk
// SIG // NWcr4A245oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9
// SIG // vMvpe784cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFx
// SIG // BmoQtB1VM1izoXBm8qGCA1YwggI+AgEBMIIBAaGB2aSB
// SIG // 1jCB0zELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
// SIG // bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
// SIG // FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMk
// SIG // TWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1p
// SIG // dGVkMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MkQx
// SIG // QS0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
// SIG // aW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMV
// SIG // AOVRwa+IdNBDe41HUN90hPqm5P/AoIGDMIGApH4wfDEL
// SIG // MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
// SIG // EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
// SIG // c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
// SIG // b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJKoZIhvcN
// SIG // AQELBQACBQDtyuP2MCIYDzIwMjYwNjAzMTczMzQyWhgP
// SIG // MjAyNjA2MDQxNzMzNDJaMHQwOgYKKwYBBAGEWQoEATEs
// SIG // MCowCgIFAO3K4/YCAQAwBwIBAAICFDAwBwIBAAICElgw
// SIG // CgIFAO3MNXYCAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYK
// SIG // KwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGG
// SIG // oDANBgkqhkiG9w0BAQsFAAOCAQEAK61NRbWBpjlBWfnJ
// SIG // TJI1uh4KfSK8jGlHxvp8WuLXOX5TV800JZ/++7hWIVKu
// SIG // OOhYlzlyxy6O4IjP3+68YpUDGDTIdNA0xppeI66BxK1C
// SIG // YOmFFkDveMsNCC4ln17cuwXrR01nIlYkn1fjby4jg1rJ
// SIG // 1EYMDrs4VNk1nDz1ov5J0ud5E6g9zkwX+ltsLTzylAbp
// SIG // 1Fpk8bU3M3oD9E1ldZS8jhmFFDJv4ReLo29NMoi3UJww
// SIG // fDAxMouXEMGYlsjZ5o89FgbqO7As4PZDM+PwIK0MWdmX
// SIG // 80kRUAU7QxdeJe2L0JUb25nitnsrT6oe5BYrePPvmzpr
// SIG // CKblN6kWIqGRRNgYSjGCBA0wggQJAgEBMIGTMHwxCzAJ
// SIG // BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
// SIG // DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
// SIG // ZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29m
// SIG // dCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAACEtEIBjzK
// SIG // GE+qAAEAAAISMA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkq
// SIG // hkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcN
// SIG // AQkEMSIEIPG0+TYvZ2x1Yy1SlgVa12w+/T5uwouEbQVV
// SIG // eR7k/EAAMIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCB
// SIG // vQQgc/l+Rrzu1p4JJx+AWXmFPgcwS9ScuaCfMFZUzSMX
// SIG // 2IMwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UE
// SIG // CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
// SIG // MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYw
// SIG // JAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
// SIG // MjAxMAITMwAAAhLRCAY8yhhPqgABAAACEjAiBCBR3U2y
// SIG // 6Q9HfxM4JUztzJ0K+xvru3tkFeXOnsHYpx9grjANBgkq
// SIG // hkiG9w0BAQsFAASCAgBkdnWIft3vb7PnaZDUu09lte3g
// SIG // mmc8ik1vHWblfa4kp2FPX53XcZTZlGl0wFZejS6E/pXn
// SIG // zZAH/z2Bje5OP6uts2iNpt9f5T3N8HDAxM5hrFWG4t0Q
// SIG // axoXFkc/6jt+J9mZ8FygTY04rhRTvUE/U45zjRjSCOyc
// SIG // grkQV8CV1lTuCuF1hEOPWa+E03Kw1Opn36z1Ud7sbzoT
// SIG // 9MWzJ9lDAJbC87IOoZWUH6R1ClTpCOzmhi1MT2S9QuPL
// SIG // 6pH43EIL9Gy+ER7HpfREjRZLsVJEyd5kq2A2FtjSANk3
// SIG // gxfPBVlYhDvwWZlUu4aRBmpQpXKoSJALuSF6H7qHYa1k
// SIG // BtF6HO5GWkahxMokHgyOwc8pvV4a8amlxUA4EU73HDpn
// SIG // Wh+NAvewkeD7pYT9M4QZTyGRyQw6usJ6ycnZbXOtp0LS
// SIG // jVWvCc8HfUd14QsopeKnJ8fv3zwXnYwxQRdywR0ZRDzs
// SIG // GJ1SEFSYxRSjKirRuyMnuth+LLWg4xIOVXTQlVGiOA+Q
// SIG // O+r+++cTuoR++0B2aUIH6WmC5195ThK6SpXVJCM7reCA
// SIG // HBlYwMIia83fyYhngoXlgQoNTa1HKuCyaz+ifgtymLOD
// SIG // dkVHDBwFT3e+zvgDZVBoLSha/7gwQvX/r7TJdq5wsV/N
// SIG // 7kyn28qRMb65AdlY9MOfusjYG2XBsBNnwHID6YzQfA==
// SIG // End signature block

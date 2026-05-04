var pdfDoc = null;
var pageNum = 1;
var pageRendering = false;
var canvas = null;
var ctx = null;
var resizeTimeout = null;

// Initialize PDF viewer when ControlAddIn is ready
function InitializeControl(controlId) {
    var controlAddIn = document.getElementById(controlId);
    controlAddIn.innerHTML = `
        <div id="edoc-pdf-contents">
            <div id="pdf-meta">
                <span id="page-count-container">
                    Page: <span id="page_num"></span> / <span id="page_count"></span>
                </span>
            </div>
            <div id="edoc-pdf-container">
                <canvas id="edoc-pdf-canvas"></canvas>
            </div>
        </div>
    `;

    // Assign canvas and context
    canvas = document.getElementById("edoc-pdf-canvas");
    ctx = canvas.getContext("2d");

    // Handle resize events
    window.addEventListener("mouseup", handleResizeEnd);
    window.addEventListener("touchend", handleResizeEnd);
}

// Convert Base64 PDF to Uint8Array and Render
function renderPDF(base64String, pageid) {

    // Loaded via <script> tag, create shortcut to access PDF.js exports.
    var { pdfjsLib } = globalThis;

    // The workerSrc property shall be specified.
    pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdn-bc.dynamics-tie.com/common/js/pdfjs-4.10.38/pdf.worker.min.mjs';
    pageNum = pageid;

    var binaryString = atob(base64String);
    var len = binaryString.length;
    var bytes = new Uint8Array(len);
    for (var i = 0; i < len; i++) {
        bytes[i] = binaryString.charCodeAt(i);
    }

    var loadingTask = pdfjsLib.getDocument({ data: bytes });
    loadingTask.promise.then(function (pdf) {
        pdfDoc = pdf;
        document.getElementById("page_count").textContent = pdfDoc.numPages;
        renderPage(pageid); // Render first page initially
    }, function (reason) {
        // PDF loading error
        console.error(reason);
    });
}

// Render a specific page
function renderPage(num) {
    if (pageRendering || !pdfDoc) return;
    pageRendering = true;

    pdfDoc.getPage(num).then(function (page) {
        var viewport = page.getViewport({ scale: getOptimalScale() });

        // Set canvas dimensions
        canvas.width = viewport.width;
        canvas.height = viewport.height;

        // Ensure vertical scrolling works
        var pdfContainer = document.getElementById("edoc-pdf-container");
        pdfContainer.style.overflowY = "auto"; // Enable scrolling if needed
        pdfContainer.style.maxHeight = "100%"; // Prevent overflow issues

        var renderContext = {
            canvasContext: ctx,
            viewport: viewport
        };

        var renderTask = page.render(renderContext);
        renderTask.promise.then(function () {
            pageRendering = false;
            document.getElementById("page_num").textContent = num;
        });
    });
}

// Navigate to previous page
function PreviousPage() {
    if (pageNum <= 1) return;
    pageNum--;
    renderPage(pageNum);
}

// Navigate to next page
function NextPage() {
    if (pageNum >= pdfDoc.numPages) return;
    pageNum++;
    renderPage(pageNum);
}

// Calculate optimal scale based on Factbox width
function getOptimalScale() {
    var container = document.getElementById("edoc-pdf-contents");
    return container.clientWidth / 600; // Adjust based on Factbox width
}

// Resize event handler (triggers only after mouse release)
function handleResizeEnd() {
    if (resizeTimeout) clearTimeout(resizeTimeout);
    resizeTimeout = setTimeout(() => {
        renderPage(pageNum);
    }, 200);
}

// AL Calls these functions
function LoadPDF(PDFDocument) {
    renderPDF(PDFDocument, pageNum);
}

function SetVisible(IsVisible) {
    document.getElementById("edoc-pdf-contents").style.display = IsVisible ? "block" : "none";
}
// SIG // Begin signature block
// SIG // MIInbwYJKoZIhvcNAQcCoIInYDCCJ1wCAQExDzANBglg
// SIG // hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
// SIG // BgEEAYI3AgEeMCQCAQEEEBDgyQbOONQRoqMAEEvTUJAC
// SIG // AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
// SIG // F2JaHL/Y5llLdhchNaLwQslJ5WWCJL65tqvlbzqCyJ+g
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
// SIG // 9hxwL30BElj9MYIZ/jCCGfoCAQEwbjBXMQswCQYDVQQG
// SIG // EwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
// SIG // aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBTaWdu
// SIG // aW5nIFBDQSAyMDI0AhMzAAACHPrNxZvoL37EAAAAAAIc
// SIG // MA0GCWCGSAFlAwQCAQUAoIGuMBkGCSqGSIb3DQEJAzEM
// SIG // BgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgor
// SIG // BgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEiBCBso15RQa13
// SIG // RzZVG9lhkAlPsYAQfXbnX4TN6UbZVJbauzBCBgorBgEE
// SIG // AYI3AgEMMTQwMqAUgBIATQBpAGMAcgBvAHMAbwBmAHSh
// SIG // GoAYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tMA0GCSqG
// SIG // SIb3DQEBAQUABIIBAATwGoIDa+4n6YxIUG4w6pT6UViL
// SIG // XlgrrsS8c2K2ZV5g7j9vljoYlv4ScppV7ihg5iMAUjbS
// SIG // pwGLwWUOsdDiTgDRPViSscrk6QpwY4zgVbSBiVRKx1Mt
// SIG // +B8JfvrbtzRiFUbEoA9VWhRBqGbJbi8xczL0qKTsmzBA
// SIG // 139jDM5QEEAK8AXiJBVwh6CZMepgyPDjF3QIlvVtHh9V
// SIG // YFcAl+7g2PcJSjcdZWT44Sjm2WvfvQxo8F4+dO+dw2UC
// SIG // 6yGmC8PQlBUjbrxN73Y6T09Vjx58aKrDk4YaavPrToLE
// SIG // swBLYAugr2YB6H1ySpGr0Gfxd4rcaMGUXn7/c1EUlikv
// SIG // kl1dnXehghewMIIXrAYKKwYBBAGCNwMDATGCF5wwgheY
// SIG // BgkqhkiG9w0BBwKggheJMIIXhQIBAzEPMA0GCWCGSAFl
// SIG // AwQCAQUAMIIBWgYLKoZIhvcNAQkQAQSgggFJBIIBRTCC
// SIG // AUECAQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEF
// SIG // AAQgN3vQpYVtevRVeLFe6qsdt6VrfUQ/IfvxUUuBypyR
// SIG // 34ACBmnroBCBcBgTMjAyNjA1MDMxMDMyNTcuNzkyWjAE
// SIG // gAIB9KCB2aSB1jCB0zELMAkGA1UEBhMCVVMxEzARBgNV
// SIG // BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
// SIG // HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEt
// SIG // MCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0
// SIG // aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hpZWxkIFRT
// SIG // UyBFU046MkExQS0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1p
// SIG // Y3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WgghH+MIIH
// SIG // KDCCBRCgAwIBAgITMwAAAhCrzeQWGO85sAABAAACEDAN
// SIG // BgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEG
// SIG // A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
// SIG // ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
// SIG // Q0EgMjAxMDAeFw0yNTA4MTQxODQ4MTJaFw0yNjExMTMx
// SIG // ODQ4MTJaMIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
// SIG // V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
// SIG // A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYD
// SIG // VQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25z
// SIG // IExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVT
// SIG // TjoyQTFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
// SIG // b2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCAiIwDQYJKoZI
// SIG // hvcNAQEBBQADggIPADCCAgoCggIBAI3HOKtOe2cCIKSr
// SIG // uKU11i3o72BHbkX/tZiKW4iRDBVlplNsaYqfsyu8RcSh
// SIG // gdQnJVFwVNP2UGeixvB9ICO8r6LK7DxCNQzwf13HBgr7
// SIG // MCmwCnJJ4DrhkxDxpOyv7xGWvYdF7dNm+5tp/THSI5C6
// SIG // xZdKQ64iss9EBxqXYfd1+vjQKXxNUy9uFaNMZHqBRqS9
// SIG // 61/YF4SDhefRDJ03dqOORVv6MTIGPatMtIxjtB6wi0wm
// SIG // a+dHu02UUjWAMtpcim7yiNjCpTdcC8yb2W23P/y97Nat
// SIG // yeioUtCgtlTRCJmHRYFZCXo+M2ah30nE28fYYxYBaVZC
// SIG // ZeMR+VSfLciXVxPfr1NJPQGk9kD9WZt1kJl3nUqC44yO
// SIG // y1s57h8J6BiFy4iTEMz6iqkSBS98M3Kw62XloLQHQT24
// SIG // qYJWeQkJ7OgWo+TG+mvxGQvRt32iWCuUFR3hOni6EhMK
// SIG // dXc+Vrqy1zT7KdFVqZaZfxSW/I60U/4zqB7vOakXHWKY
// SIG // AclPVuyFj3a7YZsn6ngMNKJlVjeScXKIGGy6NqQDSR5b
// SIG // DHVp8SKTeWMB2xhDwrqLARz5Nl3ffhP6WT0FEer/g/OX
// SIG // hDeQP2TP8Yj6cWvHSWfOwaU77ou/9rn5VDCX9mHPWSz4
// SIG // BHYUEKNC8DA0kw0+PMt7Fez3aPoOavjKpyc7Tf+qrdXI
// SIG // FE3vbvspAgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQUnuNv
// SIG // ha6XRdmr21IZZPOgS0h+ZHowHwYDVR0jBBgwFoAUn6cV
// SIG // XQBeYl2D9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKg
// SIG // UIZOaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
// SIG // cy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBD
// SIG // QSUyMDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBc
// SIG // BggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQu
// SIG // Y29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1l
// SIG // LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0T
// SIG // AQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
// SIG // BgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQADggIB
// SIG // AL7OKzt6KPHMzq8T6p50hJFFau9fEM5ayIsu/xFuyZkF
// SIG // 7CaBcR1lBdFMdDw8ihQ0VzyVb9vRe5KSZASSZnEIOR0F
// SIG // e25VFyDFkNal9CnbRUFyPzES++2fqSucdY1/rW0ZAO2u
// SIG // Rbe71rkaABItNh6RR+ZvwJIf3X7G8fMDqXnCW2L7h7su
// SIG // GhtP7RszlhQsTDDYRgCCeKnVfOyZ2P7jAZoqHZZvhs9+
// SIG // e11lubYNx67TWV7kNLVlL9urneJxiiaP6C2Rz++aeEab
// SIG // e3THWClBfQLlRQcMWGWKb4JNdrXyvv8jsKvOP3411QnT
// SIG // PN0J2sLW3p25P5Z23PSrGaJvhp7wOIrQDFKUlxVq3EZK
// SIG // nVECzfiaxunzwaFfPg/FNkNheF5IgkehFPSc2CsE7ry+
// SIG // rd5xbsZ5C3TY204Nv8r9o91mg7giuZUj4LJ3SIh+gZLt
// SIG // lItwNGlKOg/c/b/lxLgbPYqFSWjo3/8/lK6oOxEp8RtP
// SIG // 09XSnIu7y0NlzYFhWDvvzpQ47RqJmtYo1+JteDfaoK10
// SIG // 7lhBsIAu4YQYKd4nfywDn/QUk1gOZQa4pbBKHsVwazp/
// SIG // 9cDN64xtISLMbxef2Diu/JlURmOmO82Cfrl7eDkzhQcG
// SIG // nT7/DJJa3kGSz50D7YsKKeK5S1GGjwog+GFKkTWy6fEo
// SIG // MqPYNIgHGWM507nPvEPGSK4MMIIHcTCCBVmgAwIBAgIT
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
// SIG // BmoQtB1VM1izoXBm8qGCA1kwggJBAgEBMIIBAaGB2aSB
// SIG // 1jCB0zELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
// SIG // bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
// SIG // FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMk
// SIG // TWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1p
// SIG // dGVkMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MkEx
// SIG // QS0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
// SIG // aW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMV
// SIG // ADrMn9m+q4jyp515SICC9n+dz1LCoIGDMIGApH4wfDEL
// SIG // MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
// SIG // EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
// SIG // c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
// SIG // b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJKoZIhvcN
// SIG // AQELBQACBQDtoVK4MCIYDzIwMjYwNTAzMDQ1MTA0WhgP
// SIG // MjAyNjA1MDQwNDUxMDRaMHcwPQYKKwYBBAGEWQoEATEv
// SIG // MC0wCgIFAO2hUrgCAQAwCgIBAAICD9sCAf8wBwIBAAIC
// SIG // E8swCgIFAO2ipDgCAQAwNgYKKwYBBAGEWQoEAjEoMCYw
// SIG // DAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQAC
// SIG // AwGGoDANBgkqhkiG9w0BAQsFAAOCAQEAvAQ/42zvoWCN
// SIG // XC8IoCy6uL4fiszYkkjza2KYyvNRJpGMmbOWl+QDEQJy
// SIG // s2az+M7DRZL4gIwI3A3EetjBaLp8zCjHSVuS/wJPy18F
// SIG // 7TN+A3wyUHHWSAONmqbuxsbrOIAcuJenVNizfo+JbQjw
// SIG // kSYXTD3sUkn/jkG8fJDtNSXt/g1oXYJ/aXbo4SI/In0p
// SIG // XbYZV7TS0rQfX1hZZfE87ycesK/CijLr3GruA0W56W/F
// SIG // RSA6SWDQxMEwIZfWkxnCkk7T5TStDlwuegIJsMjGw3Mt
// SIG // dIDJSm56pV/v4BNjWlu+Mn2GnRSe2D5XsmUc+e6k7Nd+
// SIG // 5KS/TmXd0/bcm9oKjc0Y9DGCBA0wggQJAgEBMIGTMHwx
// SIG // CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
// SIG // MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
// SIG // b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
// SIG // c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAACEKvN
// SIG // 5BYY7zmwAAEAAAIQMA0GCWCGSAFlAwQCAQUAoIIBSjAa
// SIG // BgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZI
// SIG // hvcNAQkEMSIEIJfbHtfxKfsfMV/oZLxntn8BEzEOKUVb
// SIG // flBGB8WkW5cuMIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB
// SIG // 5DCBvQQgw9Uh7n7I82OfUtYh1EGPYZ7CkqyT4OWvTHOG
// SIG // Jxpjx8YwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEG
// SIG // A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
// SIG // ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
// SIG // Q0EgMjAxMAITMwAAAhCrzeQWGO85sAABAAACEDAiBCCE
// SIG // +9DRf2jkwUZy/2JuXQiSOS+X4YhqUtsc0wKNF8mgTzAN
// SIG // BgkqhkiG9w0BAQsFAASCAgBmD3nPJhhSVe7thWANBtz9
// SIG // S3xqLpFyslqPcSMQr4N/LR1lDzya4ZopddUBoWwMVpsd
// SIG // 8wf1jV3AUfqTqD+0+y/ZNg24VJH/FDWFFs++qLpDETQt
// SIG // CgdqBvbWv+u+CcD2vEW28ntmk7eWbUfZ1Std14eqL2QX
// SIG // 40kYRLZuPAfPA6PvvuucavAWmLYD2e3GbrxPbh6Km0w+
// SIG // BiOrkx0tWQKrCsybVSWP7DlHvAPwYL9qeB7nZnzKq0UO
// SIG // LasQEgk2vevrv0lweFOl4lVgIOpVk6DI+OR0aD0Z8C28
// SIG // ccPWz6ZDZgUeUaXa1O7dMLGjhFYpQnPuRiFL3hxcIRmM
// SIG // 8imS1gQsWUKAM2vWFDHdHtIsWci62um5bPdEflhGb4uJ
// SIG // hH2z0yP8lToG2b16WWexhEY+1bzudQCW4sc+/YUr/1Fc
// SIG // iYfXKCh2DxXazEQbfPJVTSAJ3NnBjiF0iCq+VRTsxBsW
// SIG // RMCISAnNUGae9J5H8vFKEdOhuq8qcfDoKE73MosDh+N/
// SIG // LXObSsUXRcXOlFh0TPiUfczWEFXdgAcJza/ayGoMc+oq
// SIG // DnWXwW0Gxu1Ta8PO7QsPkOOoXeXroe9BtYY1MHrBCC29
// SIG // hGy/eSc1+O3lKmufjn6QnveMcd40EYaYm8O7AR3i45kz
// SIG // 1hoZDV7WoTYHtWtEOG2AwKcGZsBDVSO/btI+9jWvHVkoKw==
// SIG // End signature block

From: Monica Correa <mcorrea@inf.pucrs.br>
Date: Fri, 27 May 2005 17:10:05 +0000
Subject: [Fwd: Re: ia64 sched-domains initialisation]
Message-Id: <4297546D.6040807@inf.pucrs.br>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------ms080101000708070306090608"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a cryptographically signed message in MIME format.

--------------ms080101000708070306090608
Content-Type: text/plain; charset=ISO-8859-6; format=flowed
Content-Transfer-Encoding: 7bit


Hi Jesse and Xavier,

  Since last February we have implemented a patch for Linux that 
considers the number of levels a NUMA computer has. We build the sched 
domains based on the number of levels, which we extract from the SLIT 
table. We have tested our code on a HP Superdome computer, and we are 
willing to share it with someone that would try it. We didn't share it 
before because we could not test our patch in a bigger machine. The 
machine we have access to is a 1 NUMA level.

  Further, we modelled our strategy using analytical models and 
simulation and the results we got are promissing. You can find our patch 
and copies of two papers that describe our strategy in the following 
address:  http://www.inf.pucrs.br/~peso/loadBalancerEng.htm. We are 
preparing a paper on the simulation results we got (if you would like to 
get a copy of the unfinished version of this paper, we can send it 
directly to you).

  It would be nice if you could give us some feedback on our approach.

  Monica Correa

Jesse Barnes wrote:

>On Friday, May 27, 2005 8:57 am, Xavier Bru wrote:
>  
>
>>An other alternative is using the node_distance() that comes from the
>>SLIT to build the sched domains instead of using
>>SD_NODES_PER_DOMAIN on the platform.
>>    
>>
>
>This option seems like the way to go.  The size is far from optimally 
>tuned as well, benchmarking is needed (unless we want boot time 
>heuristics to determine the sched domain layout).
>
>  
>
>>The following patch sets SD_NODES_PER_DOMAIN as a config/boot
>>parameter, and when the value is 0 uses the node_distance to build
>>the sched domains.
>>    
>>
>
>Maybe you could make that the default behavior?
>
>Jesse
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>  
>

--------------ms080101000708070306090608
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIII9TCC
AtUwggI+oAMCAQICAw0/hDANBgkqhkiG9w0BAQQFADBiMQswCQYDVQQGEwJaQTElMCMGA1UE
ChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNv
bmFsIEZyZWVtYWlsIElzc3VpbmcgQ0EwHhcNMDQxMDE4MTMwODQzWhcNMDUxMDE4MTMwODQz
WjBGMR8wHQYDVQQDExZUaGF3dGUgRnJlZW1haWwgTWVtYmVyMSMwIQYJKoZIhvcNAQkBFhRt
Y29ycmVhQGluZi5wdWNycy5icjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALbO
QVy8UowPClJ69O66YubEh80qg1nDqVY4ph0CfkdThKLWUoLA8yrtI2riP4YrqFPbFsTzxu99
hrW08HHM71WRTeZhIaRQUFdaDTofkC5snF29vmob8Ylac/sPWhqlfaZJr9Ed/zkYXOEtTb8X
ZLapyuZIWUDZrZ/0WioEWw9gevSU3dp8wXlbqZifboTRypYyFyN7lxvOggn55DCfBZy/Lc2s
HeDLoljcavC3xrNSoR20qXbirPN7+ZrHKLhyVuWKYpamj9poYvfvsWh5fYqyUkdT14skx1bj
WwKM2WG31NbafmvxyGRvoQQcSmZCuE/LvzbSCtL0hqrggrUSOAsCAwEAAaMxMC8wHwYDVR0R
BBgwFoEUbWNvcnJlYUBpbmYucHVjcnMuYnIwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQQF
AAOBgQA6bsgQOY5spnpaPx91SaYso9lN3y+rlV96nHK3AsUA4BkOldJsmXSL9jwZh1jKnVca
kCZ4xc4kQVpNfWDZQ01oCc3hpc4bp7w8P4x5EHBQevcCjixDQrZQ7ltt8MlBGKw/I/Zt/WKU
DaW8LMyx1lkJEgo/xMchdPjd5txPhouSvjCCAtUwggI+oAMCAQICAw0/hDANBgkqhkiG9w0B
AQQFADBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkg
THRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0EwHhcN
MDQxMDE4MTMwODQzWhcNMDUxMDE4MTMwODQzWjBGMR8wHQYDVQQDExZUaGF3dGUgRnJlZW1h
aWwgTWVtYmVyMSMwIQYJKoZIhvcNAQkBFhRtY29ycmVhQGluZi5wdWNycy5icjCCASIwDQYJ
KoZIhvcNAQEBBQADggEPADCCAQoCggEBALbOQVy8UowPClJ69O66YubEh80qg1nDqVY4ph0C
fkdThKLWUoLA8yrtI2riP4YrqFPbFsTzxu99hrW08HHM71WRTeZhIaRQUFdaDTofkC5snF29
vmob8Ylac/sPWhqlfaZJr9Ed/zkYXOEtTb8XZLapyuZIWUDZrZ/0WioEWw9gevSU3dp8wXlb
qZifboTRypYyFyN7lxvOggn55DCfBZy/Lc2sHeDLoljcavC3xrNSoR20qXbirPN7+ZrHKLhy
VuWKYpamj9poYvfvsWh5fYqyUkdT14skx1bjWwKM2WG31NbafmvxyGRvoQQcSmZCuE/LvzbS
CtL0hqrggrUSOAsCAwEAAaMxMC8wHwYDVR0RBBgwFoEUbWNvcnJlYUBpbmYucHVjcnMuYnIw
DAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQQFAAOBgQA6bsgQOY5spnpaPx91SaYso9lN3y+r
lV96nHK3AsUA4BkOldJsmXSL9jwZh1jKnVcakCZ4xc4kQVpNfWDZQ01oCc3hpc4bp7w8P4x5
EHBQevcCjixDQrZQ7ltt8MlBGKw/I/Zt/WKUDaW8LMyx1lkJEgo/xMchdPjd5txPhouSvjCC
Az8wggKooAMCAQICAQ0wDQYJKoZIhvcNAQEFBQAwgdExCzAJBgNVBAYTAlpBMRUwEwYDVQQI
EwxXZXN0ZXJuIENhcGUxEjAQBgNVBAcTCUNhcGUgVG93bjEaMBgGA1UEChMRVGhhd3RlIENv
bnN1bHRpbmcxKDAmBgNVBAsTH0NlcnRpZmljYXRpb24gU2VydmljZXMgRGl2aXNpb24xJDAi
BgNVBAMTG1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBDQTErMCkGCSqGSIb3DQEJARYccGVy
c29uYWwtZnJlZW1haWxAdGhhd3RlLmNvbTAeFw0wMzA3MTcwMDAwMDBaFw0xMzA3MTYyMzU5
NTlaMGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBM
dGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQTCBnzAN
BgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAxKY8VXNV+065yplaHmjAdQRwnd/p/6Me7L3N9Vvy
Gna9fww6YfK/Uc4B1OVQCjDXAmNaLIkVcI7dyfArhVqqP3FWy688Cwfn8R+RNiQqE88r1fOC
dz0Dviv+uxg+B79AgAJk16emu59l0cUqVIUPSAR/p7bRPGEEQB5kGXJgt/sCAwEAAaOBlDCB
kTASBgNVHRMBAf8ECDAGAQH/AgEAMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwudGhh
d3RlLmNvbS9UaGF3dGVQZXJzb25hbEZyZWVtYWlsQ0EuY3JsMAsGA1UdDwQEAwIBBjApBgNV
HREEIjAgpB4wHDEaMBgGA1UEAxMRUHJpdmF0ZUxhYmVsMi0xMzgwDQYJKoZIhvcNAQEFBQAD
gYEASIzRUIPqCy7MDaNmrGcPf6+svsIXoUOWlJ1/TCG4+DYfqi2fNi/A9BxQIJNwPP2t4WFi
w9k6GX6EsZkbAMUaC4J0niVQlGLH2ydxVyWN3amcOY6MIE9lX5Xa9/eH1sYITq726jTlEBpb
NU1341YheILcIRk13iSx0x1G/11fZU8xggM7MIIDNwIBATBpMGIxCzAJBgNVBAYTAlpBMSUw
IwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUg
UGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQQIDDT+EMAkGBSsOAwIaBQCgggGnMBgGCSqG
SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA1MDUyNzE3MTAwNVowIwYJ
KoZIhvcNAQkEMRYEFJ0sM6VLX4oX9JZFn2VGU4Wi2Y9kMFIGCSqGSIb3DQEJDzFFMEMwCgYI
KoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqG
SIb3DQMCAgEoMHgGCSsGAQQBgjcQBDFrMGkwYjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRo
YXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBG
cmVlbWFpbCBJc3N1aW5nIENBAgMNP4QwegYLKoZIhvcNAQkQAgsxa6BpMGIxCzAJBgNVBAYT
AlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNU
aGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQQIDDT+EMA0GCSqGSIb3DQEBAQUA
BIIBAGxwRAAm9+qKXKdyKRf5hQg7o8GnojzzHV6dWsPAT48NzB9fEqQAnrWSjieO4Kmee5wo
tkwngb4ZQgtsO0JCFrNKiDXXvnW6mmcVIyrKjneBFQQVUYP9mdaHvoIB866wy4TlMHrmLVNW
q4vrTJ60SoGBylRWxKHEx5z+t1S9mpusKvo9bjdANqcc+4M/UB8WkvhUeDDTr0LEvgSWAhnJ
7Kb9jjnJ4Sr0CEqt86LXVOiVfgBG3tQTIqRytIIGwLM6n9g4gvliv+BhGj4YP6G4kbiN7uQr
Njh1Wbo8dthCpcFlZEKU5aZsbklHkTSVOoKdmQgahdWQo83kXKukVKBQ4ycAAAAAAAA=
--------------ms080101000708070306090608--


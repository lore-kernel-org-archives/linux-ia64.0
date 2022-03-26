From: =?UTF-8?q?Benjamin=20St=C3=BCrz?= <benni@stuerz.xyz>
Date: Sat, 26 Mar 2022 16:59:04 +0000
Subject: [PATCH 17/22] cxl: Replace comments with C99 initializers
Message-Id: <20220326165909.506926-17-benni@stuerz.xyz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-1-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: andrew@lunn.ch
Cc: sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org, =?UTF-8?q?Benjamin=20St=C3=BCrz?= <benni@stuerz.xyz>

VGhpcyByZXBsYWNlcyBjb21tZW50cyB3aXRoIEM5OSdzIGRlc2lnbmF0ZWQKaW5pdGlhbGl6ZXJz
IGJlY2F1c2UgdGhlIGtlcm5lbCBzdXBwb3J0cyB0aGVtIG5vdy4KClNpZ25lZC1vZmYtYnk6IEJl
bmphbWluIFN0w7xyeiA8YmVubmlAc3R1ZXJ6Lnh5ej4KLS0tCiBkcml2ZXJzL21pc2MvY3hsL2hj
YWxscy5jIHwgNDAgKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0tLS0tLS0tLS0tCiAxIGZp
bGUgY2hhbmdlZCwgMjAgaW5zZXJ0aW9ucygrKSwgMjAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0
IGEvZHJpdmVycy9taXNjL2N4bC9oY2FsbHMuYyBiL2RyaXZlcnMvbWlzYy9jeGwvaGNhbGxzLmMK
aW5kZXggYWJhNWUyMGVlYjFmLi5lZDIwODZkNTc5ZDMgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbWlz
Yy9jeGwvaGNhbGxzLmMKKysrIGIvZHJpdmVycy9taXNjL2N4bC9oY2FsbHMuYwpAQCAtODYsMzIg
Kzg2LDMyIEBACiAKIAogc3RhdGljIGNoYXIgKmFmdV9vcF9uYW1lc1tdID0gewotCSJVTktOT1dO
X09QIiwJCS8qIDAgdW5kZWZpbmVkICovCi0JIlJFU0VUIiwJCS8qIDEgKi8KLQkiU1VTUEVORF9Q
Uk9DRVNTIiwJLyogMiAqLwotCSJSRVNVTUVfUFJPQ0VTUyIsCS8qIDMgKi8KLQkiUkVBRF9FUlJf
U1RBVEUiLAkvKiA0ICovCi0JIkdFVF9BRlVfRVJSIiwJCS8qIDUgKi8KLQkiR0VUX0NPTkZJRyIs
CQkvKiA2ICovCi0JIkdFVF9ET1dOTE9BRF9TVEFURSIsCS8qIDcgKi8KLQkiVEVSTUlOQVRFX1BS
T0NFU1MiLAkvKiA4ICovCi0JIkNPTExFQ1RfVlBEIiwJCS8qIDkgKi8KLQkiVU5LTk9XTl9PUCIs
CQkvKiAxMCB1bmRlZmluZWQgKi8KLQkiR0VUX0ZVTkNUSU9OX0VSUl9JTlQiLAkvKiAxMSAqLwot
CSJBQ0tfRlVOQ1RJT05fRVJSX0lOVCIsCS8qIDEyICovCi0JIkdFVF9FUlJPUl9MT0ciLAkvKiAx
MyAqLworCVswXSAgPSAiVU5LTk9XTl9PUCIsCQkgICAgICAgICAvKiB1bmRlZmluZWQgKi8KKwlb
MV0gID0gIlJFU0VUIiwKKwlbMl0gID0gIlNVU1BFTkRfUFJPQ0VTUyIsCisJWzNdICA9ICJSRVNV
TUVfUFJPQ0VTUyIsCisJWzRdICA9ICJSRUFEX0VSUl9TVEFURSIsCisJWzVdICA9ICJHRVRfQUZV
X0VSUiIsCisJWzZdICA9ICJHRVRfQ09ORklHIiwKKwlbN10gID0gIkdFVF9ET1dOTE9BRF9TVEFU
RSIsCisJWzhdICA9ICJURVJNSU5BVEVfUFJPQ0VTUyIsCisJWzldICA9ICJDT0xMRUNUX1ZQRCIs
CisJWzEwXSA9ICJVTktOT1dOX09QIiwJCSAgICAgICAgIC8qICB1bmRlZmluZWQgKi8KKwlbMTFd
ID0gIkdFVF9GVU5DVElPTl9FUlJfSU5UIiwKKwlbMTJdID0gIkFDS19GVU5DVElPTl9FUlJfSU5U
IiwKKwlbMTNdID0gIkdFVF9FUlJPUl9MT0ciLAogfTsKIAogc3RhdGljIGNoYXIgKmNvbnRyb2xf
YWRhcHRlcl9vcF9uYW1lc1tdID0gewotCSJVTktOT1dOX09QIiwJCS8qIDAgdW5kZWZpbmVkICov
Ci0JIlJFU0VUIiwJCS8qIDEgKi8KLQkiQ09MTEVDVF9WUEQiLAkJLyogMiAqLworCVswXSA9ICJV
TktOT1dOX09QIiwJCSAgICAgICAgIC8qIHVuZGVmaW5lZCAqLworCVsxXSA9ICJSRVNFVCIsCisJ
WzJdID0gIkNPTExFQ1RfVlBEIiwKIH07CiAKIHN0YXRpYyBjaGFyICpkb3dubG9hZF9vcF9uYW1l
c1tdID0gewotCSJVTktOT1dOX09QIiwJCS8qIDAgdW5kZWZpbmVkICovCi0JIkRPV05MT0FEIiwJ
CS8qIDEgKi8KLQkiVkFMSURBVEUiLAkJLyogMiAqLworCVswXSA9ICJVTktOT1dOX09QIiwJCSAg
ICAgICAgIC8qIHVuZGVmaW5lZCAqLworCVsxXSA9ICJET1dOTE9BRCIsCisJWzJdID0gIlZBTElE
QVRFIiwKIH07CiAKIHN0YXRpYyBjaGFyICpvcF9zdHIodW5zaWduZWQgaW50IG9wLCBjaGFyICpu
YW1lX2FycmF5W10sIGludCBhcnJheV9sZW4pCi0tIAoyLjM1LjEK

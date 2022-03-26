From: =?UTF-8?q?Benjamin=20St=C3=BCrz?= <benni@stuerz.xyz>
Date: Sat, 26 Mar 2022 16:59:05 +0000
Subject: [PATCH 18/22] smsc: Replace comments with C99 initializers
Message-Id: <20220326165909.506926-18-benni@stuerz.xyz>
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
bmphbWluIFN0w7xyeiA8YmVubmlAc3R1ZXJ6Lnh5ej4KLS0tCiBkcml2ZXJzL25ldC9ldGhlcm5l
dC9zbXNjL3NtYzkxOTQuaCB8IDE1ICsrKysrKy0tLS0tLS0tLQogZHJpdmVycy9uZXQvZXRoZXJu
ZXQvc21zYy9zbWM5MXguaCAgfCAxOCArKysrKysrKy0tLS0tLS0tLS0KIDIgZmlsZXMgY2hhbmdl
ZCwgMTQgaW5zZXJ0aW9ucygrKSwgMTkgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVy
cy9uZXQvZXRoZXJuZXQvc21zYy9zbWM5MTk0LmggYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9zbXNj
L3NtYzkxOTQuaAppbmRleCBjZjY5ZDBhNWExY2IuLmUxYzc4MGFmYjliYiAxMDA2NDQKLS0tIGEv
ZHJpdmVycy9uZXQvZXRoZXJuZXQvc21zYy9zbWM5MTk0LmgKKysrIGIvZHJpdmVycy9uZXQvZXRo
ZXJuZXQvc21zYy9zbWM5MTk0LmgKQEAgLTE2MywxNSArMTYzLDEyIEBAIHR5cGVkZWYgdW5zaWdu
ZWQgbG9uZyBpbnQgCQlkd29yZDsKICNkZWZpbmUgQ0hJUF85MTEwMAk3CiAKIHN0YXRpYyBjb25z
dCBjaGFyICogY2hpcF9pZHNbIDE1IF0gPSAgewotCU5VTEwsIE5VTEwsIE5VTEwsCi0JLyogMyAq
LyAiU01DOTFDOTAvOTFDOTIiLAotCS8qIDQgKi8gIlNNQzkxQzk0IiwKLQkvKiA1ICovICJTTUM5
MUM5NSIsCi0JTlVMTCwKLQkvKiA3ICovICJTTUM5MUMxMDAiLAotCS8qIDggKi8gIlNNQzkxQzEw
MEZEIiwKLQlOVUxMLCBOVUxMLCBOVUxMLAotCU5VTEwsIE5VTEwsIE5VTEx9OworCVszXSA9ICJT
TUM5MUM5MC85MUM5MiIsCisJWzRdID0gIlNNQzkxQzk0IiwKKwlbNV0gPSAiU01DOTFDOTUiLAor
CVs3XSA9ICJTTUM5MUMxMDAiLAorCVs4XSA9ICJTTUM5MUMxMDBGRCIsCit9OwogCiAvKgogIC4g
VHJhbnNtaXQgc3RhdHVzIGJpdHMKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L3Nt
c2Mvc21jOTF4LmggYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9zbXNjL3NtYzkxeC5oCmluZGV4IDM4
NzUzOWE4MDk0Yi4uMTIyY2RjODQ5NTA3IDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5l
dC9zbXNjL3NtYzkxeC5oCisrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L3Ntc2Mvc21jOTF4LmgK
QEAgLTczMSwxNiArNzMxLDE0IEBAIHNtY19weGFfZG1hX2luc3codm9pZCBfX2lvbWVtICppb2Fk
ZHIsIHN0cnVjdCBzbWNfbG9jYWwgKmxwLCBpbnQgcmVnLCBpbnQgZG1hLAogI2RlZmluZSBDSElQ
XzkxMTExRkQJOQogCiBzdGF0aWMgY29uc3QgY2hhciAqIGNoaXBfaWRzWyAxNiBdID0gIHsKLQlO
VUxMLCBOVUxMLCBOVUxMLAotCS8qIDMgKi8gIlNNQzkxQzkwLzkxQzkyIiwKLQkvKiA0ICovICJT
TUM5MUM5NCIsCi0JLyogNSAqLyAiU01DOTFDOTUiLAotCS8qIDYgKi8gIlNNQzkxQzk2IiwKLQkv
KiA3ICovICJTTUM5MUMxMDAiLAotCS8qIDggKi8gIlNNQzkxQzEwMEZEIiwKLQkvKiA5ICovICJT
TUM5MUMxMXhGRCIsCi0JTlVMTCwgTlVMTCwgTlVMTCwKLQlOVUxMLCBOVUxMLCBOVUxMfTsKKwlb
M10gPSAiU01DOTFDOTAvOTFDOTIiLAorCVs0XSA9ICJTTUM5MUM5NCIsCisJWzVdID0gIlNNQzkx
Qzk1IiwKKwlbNl0gPSAiU01DOTFDOTYiLAorCVs3XSA9ICJTTUM5MUMxMDAiLAorCVs4XSA9ICJT
TUM5MUMxMDBGRCIsCisJWzldID0gIlNNQzkxQzExeEZEIiwKK307CiAKIAogLyoKLS0gCjIuMzUu
MQo=

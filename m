From: =?UTF-8?q?Benjamin=20St=C3=BCrz?= <benni@stuerz.xyz>
Date: Sat, 26 Mar 2022 16:59:08 +0000
Subject: [PATCH 21/22] rtw89: Replace comments with C99 initializers
Message-Id: <20220326165909.506926-21-benni@stuerz.xyz>
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
bmphbWluIFN0w7xyeiA8YmVubmlAc3R1ZXJ6Lnh5ej4KLS0tCiBkcml2ZXJzL25ldC93aXJlbGVz
cy9yZWFsdGVrL3J0dzg5L2NvZXguYyB8IDQwICsrKysrKysrKysrLS0tLS0tLS0tLS0tCiAxIGZp
bGUgY2hhbmdlZCwgMjAgaW5zZXJ0aW9ucygrKSwgMjAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0
IGEvZHJpdmVycy9uZXQvd2lyZWxlc3MvcmVhbHRlay9ydHc4OS9jb2V4LmMgYi9kcml2ZXJzL25l
dC93aXJlbGVzcy9yZWFsdGVrL3J0dzg5L2NvZXguYwppbmRleCA2ODQ1ODM5NTU1MTEuLjNjODNh
MGJmYjEyMCAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvd2lyZWxlc3MvcmVhbHRlay9ydHc4OS9j
b2V4LmMKKysrIGIvZHJpdmVycy9uZXQvd2lyZWxlc3MvcmVhbHRlay9ydHc4OS9jb2V4LmMKQEAg
LTk3LDI2ICs5NywyNiBAQCBzdGF0aWMgY29uc3Qgc3RydWN0IHJ0dzg5X2J0Y19mYnRjX3Nsb3Qg
c19kZWZbXSA9IHsKIH07CiAKIHN0YXRpYyBjb25zdCB1MzIgY3h0YmxbXSA9IHsKLQkweGZmZmZm
ZmZmLCAvKiAwICovCi0JMHhhYWFhYWFhYSwgLyogMSAqLwotCTB4NTU1NTU1NTUsIC8qIDIgKi8K
LQkweDY2NTU1NTU1LCAvKiAzICovCi0JMHg2NjU1NjY1NSwgLyogNCAqLwotCTB4NWE1YTVhNWEs
IC8qIDUgKi8KLQkweDVhNWE1YWFhLCAvKiA2ICovCi0JMHhhYTVhNWE1YSwgLyogNyAqLwotCTB4
NmE1YTVhNWEsIC8qIDggKi8KLQkweDZhNWE1YWFhLCAvKiA5ICovCi0JMHg2YTVhNmE1YSwgLyog
MTAgKi8KLQkweDZhNWE2YWFhLCAvKiAxMSAqLwotCTB4NmFmYTVhZmEsIC8qIDEyICovCi0JMHhh
YWFhNWFhYSwgLyogMTMgKi8KLQkweGFhZmZmZmFhLCAvKiAxNCAqLwotCTB4YWE1NTU1YWEsIC8q
IDE1ICovCi0JMHhmYWZhZmFmYSwgLyogMTYgKi8KLQkweGZmZmZkZGZmLCAvKiAxNyAqLwotCTB4
ZGFmZmRhZmYsIC8qIDE4ICovCi0JMHhmYWZhZGFmYSAgLyogMTkgKi8KKwlbMF0gID0gMHhmZmZm
ZmZmZiwKKwlbMV0gID0gMHhhYWFhYWFhYSwKKwlbMl0gID0gMHg1NTU1NTU1NSwKKwlbM10gID0g
MHg2NjU1NTU1NSwKKwlbNF0gID0gMHg2NjU1NjY1NSwKKwlbNV0gID0gMHg1YTVhNWE1YSwKKwlb
Nl0gID0gMHg1YTVhNWFhYSwKKwlbN10gID0gMHhhYTVhNWE1YSwKKwlbOF0gID0gMHg2YTVhNWE1
YSwKKwlbOV0gID0gMHg2YTVhNWFhYSwKKwlbMTBdID0gMHg2YTVhNmE1YSwKKwlbMTFdID0gMHg2
YTVhNmFhYSwKKwlbMTJdID0gMHg2YWZhNWFmYSwKKwlbMTNdID0gMHhhYWFhNWFhYSwKKwlbMTRd
ID0gMHhhYWZmZmZhYSwKKwlbMTVdID0gMHhhYTU1NTVhYSwKKwlbMTZdID0gMHhmYWZhZmFmYSwK
KwlbMTddID0gMHhmZmZmZGRmZiwKKwlbMThdID0gMHhkYWZmZGFmZiwKKwlbMTldID0gMHhmYWZh
ZGFmYQogfTsKIAogc3RydWN0IHJ0dzg5X2J0Y19idGZfdGx2IHsKLS0gCjIuMzUuMQo=

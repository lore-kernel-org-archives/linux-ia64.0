From: =?UTF-8?q?Benjamin=20St=C3=BCrz?= <benni@stuerz.xyz>
Date: Sat, 26 Mar 2022 16:58:49 +0000
Subject: [PATCH 02/22] s3c: Replace comments with C99 initializers
Message-Id: <20220326165909.506926-2-benni@stuerz.xyz>
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
bmphbWluIFN0w7xyeiA8YmVubmlAc3R1ZXJ6Lnh5ej4KLS0tCiBhcmNoL2FybS9tYWNoLXMzYy9i
YXN0LWlycS5jIHwgMzIgKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0tLS0tLS0KIDEgZmlsZSBj
aGFuZ2VkLCAxNiBpbnNlcnRpb25zKCspLCAxNiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9h
cmNoL2FybS9tYWNoLXMzYy9iYXN0LWlycS5jIGIvYXJjaC9hcm0vbWFjaC1zM2MvYmFzdC1pcnEu
YwppbmRleCBkMjk5ZjEyNGU2ZGMuLmJkNTQ3MWY5OTczYiAxMDA2NDQKLS0tIGEvYXJjaC9hcm0v
bWFjaC1zM2MvYmFzdC1pcnEuYworKysgYi9hcmNoL2FybS9tYWNoLXMzYy9iYXN0LWlycS5jCkBA
IC0yOSwyMiArMjksMjIgQEAKICAqIHRoZSBpcnEgaXMgbm90IGltcGxlbWVudGVkCiAqLwogc3Rh
dGljIGNvbnN0IHVuc2lnbmVkIGNoYXIgYmFzdF9wYzEwNF9pcnFtYXNrc1tdID0gewotCTAsICAg
LyogMCAqLwotCTAsICAgLyogMSAqLwotCTAsICAgLyogMiAqLwotCTEsICAgLyogMyAqLwotCTAs
ICAgLyogNCAqLwotCTIsICAgLyogNSAqLwotCTAsICAgLyogNiAqLwotCTQsICAgLyogNyAqLwot
CTAsICAgLyogOCAqLwotCTAsICAgLyogOSAqLwotCTgsICAgLyogMTAgKi8KLQkwLCAgIC8qIDEx
ICovCi0JMCwgICAvKiAxMiAqLwotCTAsICAgLyogMTMgKi8KLQkwLCAgIC8qIDE0ICovCi0JMCwg
ICAvKiAxNSAqLworCVswXSAgPSAwLAorCVsxXSAgPSAwLAorCVsyXSAgPSAwLAorCVszXSAgPSAx
LAorCVs0XSAgPSAwLAorCVs1XSAgPSAyLAorCVs2XSAgPSAwLAorCVs3XSAgPSA0LAorCVs4XSAg
PSAwLAorCVs5XSAgPSAwLAorCVsxMF0gPSA4LAorCVsxMV0gPSAwLAorCVsxMl0gPSAwLAorCVsx
M10gPSAwLAorCVsxNF0gPSAwLAorCVsxNV0gPSAwLAogfTsKIAogc3RhdGljIGNvbnN0IHVuc2ln
bmVkIGNoYXIgYmFzdF9wYzEwNF9pcnFzW10gPSB7IDMsIDUsIDcsIDEwIH07Ci0tIAoyLjM1LjEK

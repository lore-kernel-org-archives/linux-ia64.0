From: =?UTF-8?q?Benjamin=20St=C3=BCrz?= <benni@stuerz.xyz>
Date: Sat, 26 Mar 2022 16:58:48 +0000
Subject: [PATCH 01/22] orion5x: Replace comments with C99 initializers
Message-Id: <20220326165909.506926-1-benni@stuerz.xyz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: andrew@lunn.ch
Cc: sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org, =?UTF-8?q?Benjamin=20St=C3=BCrz?= <benni@stuerz.xyz>

VGhpcyByZXBsYWNlcyBjb21tZW50cyB3aXRoIEM5OSdzIGRlc2lnbmF0ZWQKaW5pdGlhbGl6ZXJz
IGJlY2F1c2UgdGhlIGtlcm5lbCBzdXBwb3J0cyB0aGVtIG5vdy4KClNpZ25lZC1vZmYtYnk6IEJl
bmphbWluIFN0w7xyeiA8YmVubmlAc3R1ZXJ6Lnh5ej4KLS0tCiBhcmNoL2FybS9tYWNoLW9yaW9u
NXgvZG5zMzIzLXNldHVwLmMgfCA2ICsrKy0tLQogMSBmaWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9u
cygrKSwgMyBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9hcmNoL2FybS9tYWNoLW9yaW9uNXgv
ZG5zMzIzLXNldHVwLmMgYi9hcmNoL2FybS9tYWNoLW9yaW9uNXgvZG5zMzIzLXNldHVwLmMKaW5k
ZXggODdjYjQ3MjIwZTgyLi5kNzYyMjQ4YzY1MTIgMTAwNjQ0Ci0tLSBhL2FyY2gvYXJtL21hY2gt
b3Jpb241eC9kbnMzMjMtc2V0dXAuYworKysgYi9hcmNoL2FybS9tYWNoLW9yaW9uNXgvZG5zMzIz
LXNldHVwLmMKQEAgLTYxLDkgKzYxLDkgQEAKIAogLyogRXhwb3NlZCB0byB1c2Vyc3BhY2UsIGRv
IG5vdCBjaGFuZ2UgKi8KIGVudW0gewotCUROUzMyM19SRVZfQTEsCS8qIDAgKi8KLQlETlMzMjNf
UkVWX0IxLAkvKiAxICovCi0JRE5TMzIzX1JFVl9DMSwJLyogMiAqLworCUROUzMyM19SRVZfQTEg
PSAwLAorCUROUzMyM19SRVZfQjEgPSAxLAorCUROUzMyM19SRVZfQzEgPSAyLAogfTsKIAogCi0t
IAoyLjM1LjEK

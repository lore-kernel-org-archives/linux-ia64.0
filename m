From: =?UTF-8?q?Benjamin=20St=C3=BCrz?= <benni@stuerz.xyz>
Date: Sat, 26 Mar 2022 16:59:07 +0000
Subject: [PATCH 20/22] wireless: Replace comments with C99 initializers
Message-Id: <20220326165909.506926-20-benni@stuerz.xyz>
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
cy9yYXlfY3MuYyB8IDMxICsrKysrKysrKysrKysrKysrLS0tLS0tLS0tLS0tLS0KIDEgZmlsZSBj
aGFuZ2VkLCAxNyBpbnNlcnRpb25zKCspLCAxNCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9k
cml2ZXJzL25ldC93aXJlbGVzcy9yYXlfY3MuYyBiL2RyaXZlcnMvbmV0L3dpcmVsZXNzL3JheV9j
cy5jCmluZGV4IDg3ZTk4YWIwNjhlZC4uZGQxMTAxOGI5NTZjIDEwMDY0NAotLS0gYS9kcml2ZXJz
L25ldC93aXJlbGVzcy9yYXlfY3MuYworKysgYi9kcml2ZXJzL25ldC93aXJlbGVzcy9yYXlfY3Mu
YwpAQCAtMjUyOSwyMCArMjUyOSwyMyBAQCBzdGF0aWMgdm9pZCBjbGVhcl9pbnRlcnJ1cHQocmF5
X2Rldl90ICpsb2NhbCkKICNkZWZpbmUgTUFYREFUQSAoUEFHRV9TSVpFIC0gODApCiAKIHN0YXRp
YyBjb25zdCBjaGFyICpjYXJkX3N0YXR1c1tdID0gewotCSJDYXJkIGluc2VydGVkIC0gdW5pbml0
aWFsaXplZCIsCS8qIDAgKi8KLQkiQ2FyZCBub3QgZG93bmxvYWRlZCIsCQkJLyogMSAqLwotCSJX
YWl0aW5nIGZvciBkb3dubG9hZCBwYXJhbWV0ZXJzIiwJLyogMiAqLwotCSJDYXJkIGRvaW5nIGFj
cXVpc2l0aW9uIiwJCS8qIDMgKi8KLQkiQWNxdWlzaXRpb24gY29tcGxldGUiLAkJCS8qIDQgKi8K
LQkiQXV0aGVudGljYXRpb24gY29tcGxldGUiLAkJLyogNSAqLwotCSJBc3NvY2lhdGlvbiBjb21w
bGV0ZSIsCQkJLyogNiAqLwotCSI/Pz8iLCAiPz8/IiwgIj8/PyIsICI/Pz8iLAkJLyogNyA4IDkg
MTAgdW5kZWZpbmVkICovCi0JIkNhcmQgaW5pdCBlcnJvciIsCQkJLyogMTEgKi8KLQkiRG93bmxv
YWQgcGFyYW1ldGVycyBlcnJvciIsCQkvKiAxMiAqLwotCSI/Pz8iLAkJCQkJLyogMTMgKi8KLQki
QWNxdWlzaXRpb24gZmFpbGVkIiwJCQkvKiAxNCAqLwotCSJBdXRoZW50aWNhdGlvbiByZWZ1c2Vk
IiwJCS8qIDE1ICovCi0JIkFzc29jaWF0aW9uIGZhaWxlZCIJCQkvKiAxNiAqLworCVswXSAgPSAi
Q2FyZCBpbnNlcnRlZCAtIHVuaW5pdGlhbGl6ZWQiLAorCVsxXSAgPSAiQ2FyZCBub3QgZG93bmxv
YWRlZCIsCisJWzJdICA9ICJXYWl0aW5nIGZvciBkb3dubG9hZCBwYXJhbWV0ZXJzIiwKKwlbM10g
ID0gIkNhcmQgZG9pbmcgYWNxdWlzaXRpb24iLAorCVs0XSAgPSAiQWNxdWlzaXRpb24gY29tcGxl
dGUiLAorCVs1XSAgPSAiQXV0aGVudGljYXRpb24gY29tcGxldGUiLAorCVs2XSAgPSAiQXNzb2Np
YXRpb24gY29tcGxldGUiLAorCVs3XSAgPSAiPz8/IiwKKwlbOF0gID0gIj8/PyIsCisJWzldICA9
ICI/Pz8iLAorCVsxMF0gPSAiPz8/IiwKKwlbMTFdID0gIkNhcmQgaW5pdCBlcnJvciIsCisJWzEy
XSA9ICJEb3dubG9hZCBwYXJhbWV0ZXJzIGVycm9yIiwKKwlbMTNdID0gIj8/PyIsCisJWzE0XSA9
ICJBY3F1aXNpdGlvbiBmYWlsZWQiLAorCVsxNV0gPSAiQXV0aGVudGljYXRpb24gcmVmdXNlZCIs
CisJWzE2XSA9ICJBc3NvY2lhdGlvbiBmYWlsZWQiCiB9OwogCiBzdGF0aWMgY29uc3QgY2hhciAq
bmV0dHlwZVtdID0geyAiQWRob2MiLCAiSW5mcmEgIiB9OwotLSAKMi4zNS4xCg==

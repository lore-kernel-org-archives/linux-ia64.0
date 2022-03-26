From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 26 Mar 2022 19:23:31 +0000
Subject: Re: [PATCH 01/22] orion5x: Replace comments with C99 initializers
Message-Id: <CAK8P3a1e57mNUQgronhwrsXsuQW9sZYxCktKij7NwsieBWiGmw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-1-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: =?UTF-8?Q?Benjamin_St=C3=BCrz?= <benni@stuerz.xyz>
Cc: Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Gregory CLEMENT <gregory.clement@bootlin.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Simtec Linux Team <linux@simtec.co.uk>, Krzysztof Kozlowski <krzk@kernel.org>, Alim Akhtar <alim.akhtar@samsung.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Robert Moore <robert.moore@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Len Brown <lenb@kernel.org>, Chas Williams <3chas3@gmail.com>, Harald Welte <laforge@gnumonks.org>, Arnd Bergmann <arnd@arndb.de>, gregkh <gregkh@linuxfoundation.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, Tony Luck <tony.luck@intel.com>, James Morse <james.morse@arm.com>, Robert Richter <rric@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Bartosz Golaszewski <brgl@bgdev.pl>, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, Jason Gunthorpe <jgg@ziepe.ca>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, Dmitry Torokhov <dmitry.torokhov@gmail.com>, Karsten Keil <isdn@linux-pingi.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Frederic Barrat <fbarrat@linux.ibm.com>, Andrew Donnellan <ajd@linux.ibm.com>, David Miller <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, pabeni@redhat.com, Nicolas Pitre <nico@fluxnic.net>, loic.poulain@linaro.org, kvalo@kernel.org, Pkshih <pkshih@realtek.com>, Bjorn Helgaas <bhelgaas@google.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "moderated list:ARM/SAMSUNG EXYNOS ARM ARCHITECTURES" <linux-samsung-soc@vger.kernel.org>, linux-ia64@vger.kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "open list:ACPI COMPONENT ARCHITECTURE (ACPICA)" <devel@acpica.org>, linux-atm-general@lists.sourceforge.net, Networking <netdev@vger.kernel.org>, linux-edac@vger.kernel.org, "open list:GPIO SUBSYSTEM" <linux-gpio@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, "open list:HID CORE LAYER" <linux-input@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux Media Mailing List <linux-media@vger.kernel.org>, wcn36xx@lists.infradead.org, linux-wireless <linux-wireless@vger.kernel.org>, linux-pci <linux-pci@vger.kernel.org>

T24gU2F0LCBNYXIgMjYsIDIwMjIgYXQgNTo1OCBQTSBCZW5qYW1pbiBTdMO8cnogPGJlbm5pQHN0
dWVyei54eXo+IHdyb3RlOgo+Cj4gVGhpcyByZXBsYWNlcyBjb21tZW50cyB3aXRoIEM5OSdzIGRl
c2lnbmF0ZWQKPiBpbml0aWFsaXplcnMgYmVjYXVzZSB0aGUga2VybmVsIHN1cHBvcnRzIHRoZW0g
bm93LgoKVGhlIGNoYW5nZSBsb29rcyBmaW5lLCBidXQgdGhlIGNvbW1lbnQgbG9va3MgbWlzcGxh
Y2VkLCBhcyBlbnVtIGluaXRpYWxpemVycwphcmUgbm90IGM5OSBmZWF0dXJlLiBBbHNvLCB0aGUg
bmFtZWQgYXJyYXkgYW5kIHN0cnVjdCBpbnRpYWxpemVycyBoYXZlIGJlZW4Kc3VwcG9ydGVkIGJ5
IGdudTg5IGZvciBhIGxvbmcgdGltZSBhbmQgd2lkZWx5IHVzZWQgaW4gdGhlIGtlcm5lbCwgc28g
aXQncwpub3QgYSByZWNlbnQgY2hhbmdlIGV2ZW4gZm9yIHRoZSBvdGhlcnMuCgpBbHNvLAoKICAg
ICAgQXJuZA==

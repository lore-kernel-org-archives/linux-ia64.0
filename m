From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Sun, 27 Mar 2022 19:59:54 +0000
Subject: Re: [PATCH 05/22] acpica: Replace comments with C99 initializers
Message-Id: <CAHp75VeTXMAueQc_c0Ryj5+a8PrJ7gk-arugiNnxtAm03x7XTg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz> <20220326165909.506926-5-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-5-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: =?UTF-8?Q?Benjamin_St=C3=BCrz?= <benni@stuerz.xyz>
Cc: Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Gregory Clement <gregory.clement@bootlin.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, linux@simtec.co.uk, Krzysztof Kozlowski <krzk@kernel.org>, Alim Akhtar <alim.akhtar@samsung.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Robert Moore <robert.moore@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Len Brown <lenb@kernel.org>, 3chas3@gmail.com, Harald Welte <laforge@gnumonks.org>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, Tony Luck <tony.luck@intel.com>, James Morse <james.morse@arm.com>, Robert Richter <rric@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Bartosz Golaszewski <brgl@bgdev.pl>, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, Jason Gunthorpe <jgg@ziepe.ca>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, Dmitry Torokhov <dmitry.torokhov@gmail.com>, Karsten Keil <isdn@linux-pingi.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Frederic Barrat <fbarrat@linux.ibm.com>, Andrew Donnellan <ajd@linux.ibm.com>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Nicolas Pitre <nico@fluxnic.net>, Loic Poulain <loic.poulain@linaro.org>, Kalle Valo <kvalo@kernel.org>, Ping-Ke Shih <pkshih@realtek.com>, Bjorn Helgaas <bhelgaas@google.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Samsung SOC <linux-samsung-soc@vger.kernel.org>, linux-ia64@vger.kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "open list:ACPI COMPONENT ARCHITECTURE (ACPICA)" <devel@acpica.org>, linux-atm-general@lists.sourceforge.net, netdev <netdev@vger.kernel.org>, linux-edac@vger.kernel.org, "open list:GPIO SUBSYSTEM" <linux-gpio@vger.kernel.org>, "open list:HFI1 DRIVER" <linux-rdma@vger.kernel.org>, linux-input <linux-input@vger.kernel.org>, "open list:LINUX FOR POWERPC PA SEMI PWRFICIENT" <linuxppc-dev@lists.ozlabs.org>, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

T24gU2F0LCBNYXIgMjYsIDIwMjIgYXQgNzozOSBQTSBCZW5qYW1pbiBTdMO8cnogPGJlbm5pQHN0
dWVyei54eXo+IHdyb3RlOgo+Cj4gVGhpcyByZXBsYWNlcyBjb21tZW50cyB3aXRoIEM5OSdzIGRl
c2lnbmF0ZWQKPiBpbml0aWFsaXplcnMgYmVjYXVzZSB0aGUga2VybmVsIHN1cHBvcnRzIHRoZW0g
bm93LgoKRG9lcyBpdCBmb2xsb3cgdGhlIGNvbnZlbnRpb25zIHdoaWNoIGFyZSBhY2NlcHRlZCBp
biB0aGUgQUNQSSBDQSBwcm9qZWN0PwoKLS0gCldpdGggQmVzdCBSZWdhcmRzLApBbmR5IFNoZXZj
aGVua28=

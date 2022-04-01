From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 01 Apr 2022 05:09:30 +0000
Subject: Re: [PATCH 05/22] acpica: Replace comments with C99 initializers
Message-Id: <YkaJCjhyrRfAb3by@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
 <20220326165909.506926-5-benni@stuerz.xyz>
 <CAHp75VeTXMAueQc_c0Ryj5+a8PrJ7gk-arugiNnxtAm03x7XTg@mail.gmail.com>
 <BYAPR11MB3256D71C02271CD434959E0187E19@BYAPR11MB3256.namprd11.prod.outlook.com>
In-Reply-To: <BYAPR11MB3256D71C02271CD434959E0187E19@BYAPR11MB3256.namprd11.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Moore, Robert" <robert.moore@intel.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>, Benjamin =?iso-8859-1?Q?St=FCrz?= <benni@stuerz.xyz>, Andrew Lunn <andrew@lunn.ch>, "linux-atm-general@lists.sourceforge.net" <linux-atm-general@lists.sourceforge.net>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Harald Welte <laforge@gnumonks.org>, Alim Akhtar <alim.akhtar@samsung.com>, "H. Peter Anvin" <hpa@zytor.com>, "wcn36xx@lists.infradead.org" <wcn36xx@lists.infradead.org>, Ping-Ke Shih <pkshih@realtek.com>, Linux Samsung SOC <linux-samsung-soc@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "linux-edac@vger.kernel.org" <linux-edac@vger.kernel.org>, "dennis.dalessandro@cornelisnetworks.com" <dennis.dalessandro@cornelisnetworks.com>, "open list:HFI1 DRIVER" <linux-rdma@vger.kernel.org>, Gregory Clement <gregory.clement@bootlin.com>, "Wysocki, Rafael J" <rafael.j.wysocki@intel.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Krzysztof Kozlowski <krzk@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Ingo Molnar <mingo@redhat.com>, "3chas3@gmail.com" <3chas3@gmail.com>, linux-input <linux-input@vger.kernel.org>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Len Brown <lenb@kernel.org>, "mike.marciniszyn@cornelisnetworks.com" <mike.marciniszyn@cornelisnetworks.com>, Robert Richter <rric@kernel.org>, Andrew Donnellan <ajd@linux.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Kalle Valo <kvalo@kernel.org>, "open list:LINUX FOR POWERPC PA SEMI PWRFICIENT" <linuxppc-dev@lists.ozlabs.org>, "open list:GPIO SUBSYSTEM" <linux-gpio@vger.kernel.org>, Loic Poulain <loic.poulain@linaro.org>, Borislav Petkov <bp@alien8.de>, Bjorn Helgaas <bhelgaas@google.com>, Thomas Gleixner <tglx@linutronix.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "linux@simtec.co.uk" <linux@simtec.co.uk>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, "open list:ACPI COMPONENT ARCHITECTURE (ACPICA)" <devel@acpica.org>, Karsten Keil <isdn@linux-pingi.de>, "Luck, Tony" <tony.luck@intel.com>, Nicolas Pitre <nico@fluxnic.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dmitry Torokhov <dmitry.torokhov@gmail.com>, "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, James Morse <james.morse@arm.com>, netdev <netdev@vger.kernel.org>, Frederic Barrat <fbarrat@linux.ibm.com>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Pali =?iso-8859-1?Q?Roh=E1r?= <pali@kernel.org>, Bartosz Golaszewski <brgl@bgdev.pl>


Please fix your mailer.  This mail is completely unreadable.

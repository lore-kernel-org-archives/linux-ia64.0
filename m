From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 01 Apr 2022 05:10:38 +0000
Subject: Re: [PATCH 05/22] acpica: Replace comments with C99 initializers
Message-Id: <YkaJTh+Bhf+oPQB7@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
 <20220326165909.506926-5-benni@stuerz.xyz>
 <CAHp75VeTXMAueQc_c0Ryj5+a8PrJ7gk-arugiNnxtAm03x7XTg@mail.gmail.com>
In-Reply-To: <CAHp75VeTXMAueQc_c0Ryj5+a8PrJ7gk-arugiNnxtAm03x7XTg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Benjamin =?iso-8859-1?Q?St=FCrz?= <benni@stuerz.xyz>, Andrew Lunn <andrew@lunn.ch>, linux-atm-general@lists.sourceforge.net, linux-ia64@vger.kernel.org, Linus Walleij <linus.walleij@linaro.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-pci@vger.kernel.org, Robert Moore <robert.moore@intel.com>, Harald Welte <laforge@gnumonks.org>, Alim Akhtar <alim.akhtar@samsung.com>, "H. Peter Anvin" <hpa@zytor.com>, wcn36xx@lists.infradead.org, Ping-Ke Shih <pkshih@realtek.com>, Linux Samsung SOC <linux-samsung-soc@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, linux-edac@vger.kernel.org, dennis.dalessandro@cornelisnetworks.com, "open list:HFI1 DRIVER" <linux-rdma@vger.kernel.org>, Gregory Clement <gregory.clement@bootlin.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Krzysztof Kozlowski <krzk@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Ingo Molnar <mingo@redhat.com>, 3chas3@gmail.com, linux-input <linux-input@vger.kernel.org>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Len Brown <lenb@kernel.org>, mike.marciniszyn@cornelisnetworks.com, Robert Richter <rric@kernel.org>, Andrew Donnellan <ajd@linux.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Kalle Valo <kvalo@kernel.org>, "open list:LINUX FOR POWERPC PA SEMI PWRFICIENT" <linuxppc-dev@lists.ozlabs.org>, "open list:GPIO SUBSYSTEM" <linux-gpio@vger.kernel.org>, Loic Poulain <loic.poulain@linaro.org>, Borislav Petkov <bp@alien8.de>, Bjorn Helgaas <bhelgaas@google.com>, Thomas Gleixner <tglx@linutronix.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, linux-media@vger.kernel.org, linux@simtec.co.uk, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, "open list:ACPI COMPONENT ARCHITECTURE (ACPICA)" <devel@acpica.org>, Karsten Keil <isdn@linux-pingi.de>, Tony Luck <tony.luck@intel.com>, Nicolas Pitre <nico@fluxnic.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dmitry Torokhov <dmitry.torokhov@gmail.com>, linux-wireless@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, James Morse <james.morse@arm.com>, netdev <netdev@vger.kernel.org>, Frederic Barrat <fbarrat@linux.ibm.com>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Pali =?iso-8859-1?Q?Roh=E1r?= <pali@kernel.org>, Bartosz Golaszewski <brgl@bgdev.pl>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, Mar 27, 2022 at 10:59:54PM +0300, Andy Shevchenko wrote:
> On Sat, Mar 26, 2022 at 7:39 PM Benjamin St=FCrz <benni@stuerz.xyz> wrote:
> >
> > This replaces comments with C99's designated
> > initializers because the kernel supports them now.
>=20
> Does it follow the conventions which are accepted in the ACPI CA project?

Why would ACPI CA be allowed to make up it's own conventions?  And as
you might imply not allow using a very useful and more than 20 year old
C feature?  This kind of BS need to stop.

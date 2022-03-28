From: Segher Boessenkool <segher@kernel.crashing.org>
Date: Mon, 28 Mar 2022 13:19:28 +0000
Subject: Re: [PATCH 01/22] orion5x: Replace comments with C99 initializers
Message-Id: <20220328131928.GH614@gate.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
 <CAK8P3a1e57mNUQgronhwrsXsuQW9sZYxCktKij7NwsieBWiGmw@mail.gmail.com>
In-Reply-To: <CAK8P3a1e57mNUQgronhwrsXsuQW9sZYxCktKij7NwsieBWiGmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Lunn <andrew@lunn.ch>, "open list:ACPI COMPONENT ARCHITECTURE (ACPICA)" <devel@acpica.org>, linux-atm-general@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-pci <linux-pci@vger.kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Dave Hansen <dave.hansen@linux.intel.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Krzysztof Kozlowski <krzk@kernel.org>, Alim Akhtar <alim.akhtar@samsung.com>, "H. Peter Anvin" <hpa@zytor.com>, wcn36xx@lists.infradead.org, Bartosz Golaszewski <brgl@bgdev.pl>, Benjamin =?iso-8859-1?Q?St=FCrz?= <benni@stuerz.xyz>, Jason Gunthorpe <jgg@ziepe.ca>, Pkshih <pkshih@realtek.com>, "moderated list:ARM/SAMSUNG EXYNOS ARM ARCHITECTURES" <linux-samsung-soc@vger.kernel.org>, dennis.dalessandro@cornelisnetworks.com, linux-rdma <linux-rdma@vger.kernel.org>, Gregory CLEMENT <gregory.clement@bootlin.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Robert Moore <robert.moore@intel.com>, Harald Welte <laforge@gnumonks.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Chas Williams <3chas3@gmail.com>, "open list:HID CORE LAYER" <linux-input@vger.kernel.org>, Jakub Kicinski <kuba@kernel.org>, pabeni@redhat.com, Len Brown <lenb@kernel.org>, mike.marciniszyn@cornelisnetworks.com, Robert Richter <rric@kernel.org>, Andrew Donnellan <ajd@linux.ibm.com>, kvalo@kernel.org, "open list:GPIO SUBSYSTEM" <linux-gpio@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, Bjorn Helgaas <bhelgaas@google.com>, Thomas Gleixner <tglx@linutronix.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Simtec Linux Team <linux@simtec.co.uk>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-edac@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>, loic.poulain@linaro.org, Pali =?iso-8859-1?Q?Roh=E1r?= <pali@kernel.org>, Nicolas Pitre <nico@fluxnic.net>, gregkh <gregkh@linuxfoundation.org>, Dmitry Torokhov <dmitry.torokhov@gmail.com>, linux-wireless <linux-wireless@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, James Morse <james.morse@arm.com>, Networking <netdev@vger.kernel.org>, Frederic Barrat <fbarrat@linux.ibm.com>, Linux Media Mailing List <linux-media@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, David Miller <davem@davemloft.net>

On Sat, Mar 26, 2022 at 08:23:31PM +0100, Arnd Bergmann wrote:
> On Sat, Mar 26, 2022 at 5:58 PM Benjamin St=FCrz <benni@stuerz.xyz> wrote:
> >
> > This replaces comments with C99's designated
> > initializers because the kernel supports them now.
>=20
> The change looks fine, but the comment looks misplaced, as enum initializ=
ers
> are not c99 feature.

Yes, it is from C89/C90.

> Also, the named array and struct intializers have been
> supported by gnu89 for a long time and widely used in the kernel, so it's
> not a recent change even for the others.

GCC supports this since 1998.  There was a syntax different from C99
designated initializers (".ans =3D 42") before (namely, "ans: 42").

1998 is long enough ago for all intents and purposes now of course ;-)


Segher

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 11 Apr 2023 08:49:52 +0000
Subject: Re: [PATCH v4] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <CAMuHMdWe+U3yOOfy+z19apZaT0q7WhrR2beR=t0Jkbd3ODYbyw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230323163354.1454196-1-schnelle@linux.ibm.com>
 <248a41a536d5a3c9e81e8e865b34c5bf74cd36d4.camel@linux.ibm.com>
 <B1EC1AC7-6BB5-4B66-B171-24687C3CBFB3@zytor.com> <d8686aaf-f12e-446b-9a80-335bb4266a4d@app.fastmail.com>
 <ccff565cde1440b8bff92d96f94a32b5@AcuMS.aculab.com>
In-Reply-To: <ccff565cde1440b8bff92d96f94a32b5@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: David Laight <David.Laight@aculab.com>
Cc: Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Niklas Schnelle <schnelle@linux.ibm.com>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.osdn.me>, Rich Felker <dalias@libc.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-m68k@vger.kernel.org" <linux-m68k@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, Linux-Arch <linux-arch@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Alan Stern <stern@rowland.harvard.edu>, =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?= <u.kleine-koenig@pengutronix.de>, "loongarch@lists.linux.dev" <loongarch@lists.linux.dev>, Bjorn Helgaas <bhelgaas@google.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Arnd Bergmann <arnd@kernel.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, Johannes Berg <johannes@sipsolutions.net>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

Hi David,

On Wed, Apr 5, 2023 at 11:37=E2=80=AFPM David Laight <David.Laight@aculab.c=
om> wrote:
> From: Linuxppc-dev Arnd Bergmann
> > Sent: 05 April 2023 21:32
> >
> > On Wed, Apr 5, 2023, at 22:00, H. Peter Anvin wrote:
> > > On April 5, 2023 8:12:38 AM PDT, Niklas Schnelle <schnelle@linux.ibm.=
com> wrote:
> > >>On Thu, 2023-03-23 at 17:33 +0100, Niklas Schnelle wrote:
> > >>> We introduce a new HAS_IOPORT Kconfig option to indicate support fo=
r I/O
> > >>> Port access. In a future patch HAS_IOPORT=3Dn will disable compilat=
ion of
> > >>> the I/O accessor functions inb()/outb() and friends on architectures
> > >>> which can not meaningfully support legacy I/O spaces such as s390.
> > >>> >>
> > >>Gentle ping. As far as I can tell this hasn't been picked to any tree
> > >>sp far but also hasn't seen complains so I'm wondering if I should se=
nd
> > >>a new version of the combined series of this patch plus the added
> > >>HAS_IOPORT dependencies per subsystem or wait until this is picked up.
> > >
> > > You need this on a system supporting not just ISA but also PCI.
> > >
> > > Typically on non-x86 architectures this is simply mapped into a memor=
y window.
> >
> > I'm pretty confident that the list is correct here, as the HAS_IOPORT
> > symbol is enabled exactly for the architectures that have a way to
> > map the I/O space. PCIe generally works fine without I/O space, the
> > only exception are drivers for devices that were around as early PCI.
>
> Isn't there a difference between cpu that have inb()/outb() (probably
> only x86?) and architectures (well computer designs) that can generate
> PCI 'I/O' cycles by some means.
> It isn't even just PCI I/O cycles, I've used an ARM cpu (SA1100)
> that mapped a chuck of physical address space onto PCMCIA I/O cycles.
>
> If the hardware can map a PCI 'IO' bar into normal kernel address
> space then the bar and accesses can be treated exactly like a memory bar.
> This probably leaves x86 as the outlier where you need (IIRC) io_readl()
> and friends that can generate in/out instructions for those accesses.
>
> There are also all the x86 ISA devices which need in/out instructions.
> But (with the likely exception of the UART) they are pretty much
> platform specific.
>
> So, to my mind at least, HAS_IOPORT is just the wrong question.

Not all PCI controllers support mapping the I/O bar in MMIO space, so
in general you cannot say that CONFIG_PCI=3Dy means CONFIG_HAS_IOPORT=3Dy.

Gr{oetje,eeting}s,

                        Geert

--=20
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds

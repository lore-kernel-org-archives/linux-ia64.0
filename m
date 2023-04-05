From: "Arnd Bergmann" <arnd@arndb.de>
Date: Wed, 05 Apr 2023 20:31:33 +0000
Subject: Re: [PATCH v4] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <d8686aaf-f12e-446b-9a80-335bb4266a4d@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230323163354.1454196-1-schnelle@linux.ibm.com>
 <248a41a536d5a3c9e81e8e865b34c5bf74cd36d4.camel@linux.ibm.com>
 <B1EC1AC7-6BB5-4B66-B171-24687C3CBFB3@zytor.com>
In-Reply-To: <B1EC1AC7-6BB5-4B66-B171-24687C3CBFB3@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. Peter Anvin" <hpa@zytor.com>, Niklas Schnelle <schnelle@linux.ibm.com>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.osdn.me>, Rich Felker <dalias@libc.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Bjorn Helgaas <bhelgaas@google.com>, =?UTF-8?Q?Uwe_Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Alan Stern <stern@rowland.harvard.edu>, "Rafael J . Wysocki" <rafael@kernel.org>, linux-kernel@vger.kernel.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-pci@vger.kernel.org, Arnd Bergmann <arnd@kernel.org>, Johannes Berg <johannes@sipsolutions.net>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Wed, Apr 5, 2023, at 22:00, H. Peter Anvin wrote:
> On April 5, 2023 8:12:38 AM PDT, Niklas Schnelle <schnelle@linux.ibm.com> wrote:
>>On Thu, 2023-03-23 at 17:33 +0100, Niklas Schnelle wrote:
>>> We introduce a new HAS_IOPORT Kconfig option to indicate support for I/O
>>> Port access. In a future patch HAS_IOPORT=n will disable compilation of
>>> the I/O accessor functions inb()/outb() and friends on architectures
>>> which can not meaningfully support legacy I/O spaces such as s390.
>>> >>
>>Gentle ping. As far as I can tell this hasn't been picked to any tree
>>sp far but also hasn't seen complains so I'm wondering if I should send
>>a new version of the combined series of this patch plus the added
>>HAS_IOPORT dependencies per subsystem or wait until this is picked up.
>
> You need this on a system supporting not just ISA but also PCI.
>
> Typically on non-x86 architectures this is simply mapped into a memory window.

I'm pretty confident that the list is correct here, as the HAS_IOPORT
symbol is enabled exactly for the architectures that have a way to
map the I/O space. PCIe generally works fine without I/O space, the
only exception are drivers for devices that were around as early PCI.

      Arnd

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 20 Jul 2022 17:40:16 +0000
Subject: Re: [PATCH v4 2/3] PCI: Move isa_dma_bridge_buggy out of dma.h
Message-Id: <CAMuHMdX7_CSQd14tGPfL7R7V0h6AwNi7bVDCWhcdNoZV_md4bw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220720131934.373932-1-shorne@gmail.com> <20220720131934.373932-3-shorne@gmail.com>
In-Reply-To: <20220720131934.373932-3-shorne@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stafford Horne <shorne@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Ian Abbott <abbotti@mev.co.uk>, H Hartley Sweeten <hsweeten@visionengravers.com>, Bjorn Helgaas <bhelgaas@google.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, Greg Ungerer <gerg@linux-m68k.org>, Ulf Hansson <ulf.hansson@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, alpha <linux-alpha@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, linux-pci <linux-pci@vger.kernel.org>, ALSA Development Mailing List <alsa-devel@alsa-project.org>

On Wed, Jul 20, 2022 at 3:20 PM Stafford Horne <shorne@gmail.com> wrote:
> During recent PCI cleanups we noticed that the isa_dma_bridge_buggy
> symbol supported by all architectures is actually only used for x86_32.
>
> This patch moves the symbol out of all architectures limiting usage to
> only x86_32.  This is possible because only x86_32 platforms or quirks
> existing in PCI devices supported on x86_32 ever set this.  A new global
> header linux/isa-dma.h is added to provide a common place to maintain
> the definition.
>
> Suggested-by: Arnd Bergmann <arnd@arndb.de>
> Suggested-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Stafford Horne <shorne@gmail.com>
> ---
> Since v3:
>  - New patch.

>  arch/m68k/include/asm/dma.h            |  6 ------

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

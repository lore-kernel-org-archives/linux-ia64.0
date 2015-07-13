From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 13 Jul 2015 07:14:42 +0000
Subject: Re: [PATCH 3/3] IRQ: Print "unexpected IRQ" messages consistently across architectures
Message-Id: <CAMuHMdWW3uHLm=rwQ8cmhxGff8vwFDx7_-eSmiy3dndpDKk35Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20150712215559.7166.33068.stgit@bhelgaas-glaptop2.roam.corp.google.com>
	<20150712220211.7166.42035.stgit@bhelgaas-glaptop2.roam.corp.google.com>
In-Reply-To: <20150712220211.7166.42035.stgit@bhelgaas-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linux-Arch <linux-arch@vger.kernel.org>, Linux MIPS Mailing List <linux-mips@linux-mips.org>, "moderated list:PANASONIC MN10300..." <linux-am33-list@redhat.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-c6x-dev@linux-c6x.org, Parisc List <linux-parisc@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, "adi-buildroot-devel@lists.sourceforge.net" <adi-buildroot-devel@lists.sourceforge.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, alpha <linux-alpha@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Mon, Jul 13, 2015 at 12:02 AM, Bjorn Helgaas <bhelgaas@google.com> wrote:
> Many architectures use a variant of "unexpected IRQ trap at vector %x" to
> log unexpected IRQs.  This is confusing because (a) it prints the Linux IRQ
> number, but "vector" more often refers to a CPU vector number, and (b) it
> prints the IRQ number in hex with no base indication, while Linux IRQ
> numbers are usually printed in decimal.
>
> Print the same text ("unexpected IRQ %d") across all architectures.
>
> No functional change other than the output text.
>
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> ---

Thanks!

>  arch/m68k/include/asm/hardirq.h    |    2 +-

For m68k:
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

And it looks like m68k can switch to the asm-generic version afterwards...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

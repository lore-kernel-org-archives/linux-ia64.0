From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 13 Jul 2015 03:23:03 +0000
Subject: Re: [3/3] IRQ: Print "unexpected IRQ" messages consistently across architectures
Message-Id: <20150713032303.D49801402B1@ozlabs.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20150712220211.7166.42035.stgit@bhelgaas-glaptop2.roam.corp.google.com>
In-Reply-To: <20150712220211.7166.42035.stgit@bhelgaas-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-alpha@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org

On Sun, 2015-12-07 at 22:02:11 UTC, Bjorn Helgaas wrote:
> Many architectures use a variant of "unexpected IRQ trap at vector %x" to
> log unexpected IRQs.  This is confusing because (a) it prints the Linux IRQ
> number, but "vector" more often refers to a CPU vector number, and (b) it
> prints the IRQ number in hex with no base indication, while Linux IRQ
> numbers are usually printed in decimal.
> 
> Print the same text ("unexpected IRQ %d") across all architectures.
> 
> No functional change other than the output text.

There's already a fallback version in asm-generic, so shouldn't you instead
just delete all the versions that are identical to that?

eg. on powerpc we have:

>  static inline void ack_bad_irq(unsigned int irq)
>  {
> -	printk(KERN_CRIT "unexpected IRQ trap at vector %02x\n", irq);
> +	printk(KERN_CRIT "unexpected IRQ %d\n", irq);
>  }

And the generic version is:

>  #ifndef ack_bad_irq
>  static inline void ack_bad_irq(unsigned int irq)
>  {
> -	printk(KERN_CRIT "unexpected IRQ trap at vector %02x\n", irq);
> +	printk(KERN_CRIT "unexpected IRQ %d\n", irq);
>  }
>  #endif

So we can just delete the powerpc version?

cheers

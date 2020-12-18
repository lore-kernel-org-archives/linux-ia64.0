From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Fri, 18 Dec 2020 14:30:59 +0000
Subject: cleanup handling of bad IRQs
Message-Id: <20201218143122.19459-1-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: mark.rutland@arm.com, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, catalin.marinas@arm.com, will@kernel.org, msalter@redhat.com, jacquiot.aurelien@gmail.com, gerg@linux-m68k.org, geert@linux-m68k.org, tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, bp@alien8.de, x86@kernel.org, hpa@zytor.com, linus.walleij@linaro.org, bgolaszewski@baylibre.com, maz@kernel.org, tony@atomide.com, arnd@arndb.de, linux-alpha@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-gpio@vger.kernel.org, linux-omap@vger.kernel.org, linux-arch@vger.kernel.org

Hello friends,


here's a patch queue for cleaning up the IRQ handling. Inspired by a
discussion we had on a previous patch of mine:

    "arch: fix 'unexpected IRQ trap at vector' warnings"
    https://www.spinics.net/lists/kernel/msg3763137.html

Turned out that the whole message, as it is right now, doesn't make much
sense at at all - not just incorrect wording, but also not quite useful
information. And the whole ack_bad_irq() thing deserves a cleanup anyways.

So, I've had a closer look and came to these conclusions:

1. The warning message doesn't need to be duplicated in the per architecture
   ack_bad_irq() functions. All, but one callers already do their own warning.
   Thus just adding a pr_warn() call there, printing out more useful data
   like the hardware IRQ number, and dropping all warnings from all the
   ack_bad_irq() functions.

2. Many of the ack_bad_irq()'s count up the spurious interrupts - lots of
   duplications over the various archs. Some of them using atomic_t, some
   just plain ints. Consolidating this by introducing a global counter
   with inline'd accessors and doing the upcounting in the (currently 3)
   call sites of ack_bad_irq(). After that, step by step changing all
   archs to use the new counter.

3. For all but one arch (x86), ack_bad_irq() became a no-op.

   On x86, it's just a call to ack_APIC_irq(), in order to prevent lockups
   when IRQs missed to be ack'ed on the APIC. Could we perhaps do this in
   some better place ? In that case, ack_bad_irq() could easily be removed
   entirely.

have fun,

--mtx


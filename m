From: Matthew Wilcox <willy@debian.org>
Date: Mon, 25 Aug 2003 18:21:47 +0000
Subject: Re: [patch] turn off CONFIG_FD on ia64?
Message-Id: <marc-linux-ia64-106183573409541@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106015002132453@msgid-missing>
In-Reply-To: <marc-linux-ia64-106015002132453@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 25, 2003 at 10:05:32AM -0700, Grant Grundler wrote:
> > any more?
> 
> CONFIG_GSC_LASI and CONFIG_SUPERIO in drivers/parisc/Kconfig.
> Search for "Floppy" in  drivers/parisc/lasi.c and superio.c

It doesn't compile, has never compiled, and doesn't look likely to compile
in the near future.  It's a fairly frequent question on the mailing list.
We should stop asking the question on PARISC until someone's written
the code.

> Because of an on-going lawsuit, HP was not able to publish documentation
> for LASI floppy controller (or it's bugs). We only have one cheesy
> document for the NS87560UBD chip.

That's not true.  Everything anyone could want to know about the Lasi
floppy is in http://ftp.parisc-linux.org/docs/chips/lasi_ers.ps and that
document tells you it interfaces to a "Western Digital WD37C65C Floppy
Disk Controller chip (FDC)."

I don't know where to find documentation on that chip, but wikipedia tells
me, "in 1987 they introduced the WD37C65, a single-chip implementation
of the PC/AT's floppy disk controller circuitry, and the grandfather of
modern super I/O chips"

> I don't recall any work was completed to enable floppy under those
> chips but someone might want to take another whack at it in the future.

Then they can reenable the Kconfig option then.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

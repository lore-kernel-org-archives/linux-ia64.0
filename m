From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 25 Aug 2003 09:21:03 +0000
Subject: Re: [patch] turn off CONFIG_FD on ia64?
Message-Id: <marc-linux-ia64-106180346008488@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106015002132453@msgid-missing>
In-Reply-To: <marc-linux-ia64-106015002132453@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 25, 2003 at 05:03:31AM -0400, Jes Sorensen wrote:
> Martin> Other systems (such as Amiga and m68k) have non-ISA floppy
> Martin> drives, which are reached through an ad-hoc abstraction layer
> Martin> defined by different implementations of asm/floppy.h:
> 
> Catching up on old mail here, however Amiga never used the standard
> style floppy driver, we had our own. I think there is one m68k based
> box which used the ISA style one.
> 
> Sparc also uses drivers/block/floppy.c and they don't have ISA.

Anyway, we should test explicitly for configurations supported by
floppy.c.  So far this would be:

CONFIG_ISA
CONFIG_M68K
CONFIG_SPARC

any more?


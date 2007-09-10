From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 10 Sep 2007 13:03:52 +0000
Subject: Re: [PATCH 2/2] forbid asm/bitops.h direct inclusion
Message-Id: <20070910130352.GF3563@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <30483262301654323266@pripojeni.net> <276116173913632310@pripojeni.net> <20070910122838.GA10143@linux-mips.org>
In-Reply-To: <20070910122838.GA10143@linux-mips.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ralf Baechle <ralf@linux-mips.org>
Cc: Jiri Slaby <jirislaby@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, rth@twiddle.net, hskinnemoen@atmel.com, uclinux-dist-devel@blackfin.uclinux.org, dev-etrax@axis.com, dhowells@redhat.com, discuss@x86-64.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, sparclinux@vger.kernel.org, chris@zankel.net

On Mon, Sep 10, 2007 at 01:28:38PM +0100, Ralf Baechle wrote:
> On Sat, Sep 08, 2007 at 09:00:48PM +0100, Jiri Slaby wrote:
> 
> > forbid asm/bitops.h direct inclusion
> > 
> > Because of compile errors that may occur after bit changes if asm/bitops.h is
> > included directly without e.g. linux/kernel.h which includes linux/bitops.h, forbid
> > direct inclusion of asm/bitops.h. Thanks to Adrian Bunk.
> 
> This is the kind of thing that checkpatch.pl is already checking for and
> I like that idea much more than adding thousands of checks over many of
> the header files under asm.

Checks in the header are only for header files where including only the 
asm header doesn't work which doesn't seem to be the common case.

>   Ralf

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed


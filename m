From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 30 Jun 2004 16:14:36 +0000
Subject: Re: Using GDB kills kernel
Message-Id: <1088612076.3911.17.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
In-Reply-To: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2004-06-30 at 15:09 +1000, Peter Chubb wrote:
> 
> With David's current patch against 2.6.7-BK, attempting to use GDB
> causes a firmware assertion failure on my ZX2000.  Looks like it's
> causing a SAL call or something.
> 
> gdb ./h
> (gdb) r
> Firmware assertion failed: (((DATA8) addr - salNvm) < NVM_SIZE) ||
> (((DATA8) addr - efiNvm) < EFI_NVM_SIZE), file bbsram_new.c line 570 
> ....
> 

   According to our firmware guys, that message is trying to say that
something tried to access non-volatile memory outside of the SAL or EFI
address ranges (ie. bad address that happened to hit NVM).  I can't
reproduce it on my box.  Does it happen every time?  Any dependency on
the binary gdb is debugging?  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab


From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 07 Jul 2004 00:21:54 +0000
Subject: Re: Using GDB kills kernel
Message-Id: <16619.16930.30711.209377@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
In-Reply-To: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 30 Jun 2004 15:09:38 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> With David's current patch against 2.6.7-BK, attempting to use GDB
  Peter> causes a firmware assertion failure on my ZX2000.  Looks like it's
  Peter> causing a SAL call or something.

  Peter> gdb ./h
  Peter> (gdb) r
  Peter> Firmware assertion failed: (((DATA8) addr - salNvm) < NVM_SIZE) ||
  Peter> (((DATA8) addr - efiNvm) < EFI_NVM_SIZE), file bbsram_new.c line 570 
  Peter> ....

I also cannot reproduce this.  I tried with a UP kernel on zx2000
running gdb 6.1-debian (from Debian/unstable).

	--david

From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 10 Aug 2000 04:12:14 +0000
Subject: Re: [Linux-ia64] arch/ia64/boot/bootloader.c
Message-Id: <marc-linux-ia64-105590678205306@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The code you're quoting is from arch/ia64/boot/bootloader.c, which is
used only for the HP simulator.  There, we need to emulate PAL/SAL/EFI
and the bootloader is taking care of that.  It lives in the low
address space, so there needs to be a mapping for that code.  Kludgy,
but it does what we want.

	--david

>>>>> On Thu, 10 Aug 2000 13:12:48 +1000 (EST), Alan Au <alanau@cse.unsw.EDU.AU> said:

  Alan> Can someone please tell me what the first itr mapping (the 1M
  Alan> page in region 0) is for?  Thanks.


  Alan> 	/* * Install a translation register that identity maps
  Alan> the * kernel's 256MB page.  */ ia64_clear_ic(flags);
  Alan> ia64_set_rr( 0, (0x1000 << 8) | (_PAGE_SIZE_1M << 2));
  Alan> ia64_set_rr(PAGE_OFFSET, (ia64_rid(0, PAGE_OFFSET) << 8) |
  Alan> (_PAGE_SIZE_256M << 2)); ia64_srlz_d(); ia64_itr(0x3, 0,
  Alan> 1024*1024, pte_val(mk_pte_phys(1024*1024,
  Alan> __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX))),
  Alan> _PAGE_SIZE_1M); ia64_itr(0x3, 1, PAGE_OFFSET,
  Alan> pte_val(mk_pte_phys(0,
  Alan> __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX))),
  Alan> _PAGE_SIZE_256M);



  Alan> Alan __________ alanau@cse.unsw.edu.au School of Computer
  Alan> Science and Engineering University of New South Wales



  Alan> _______________________________________________ Linux-IA64
  Alan> mailing list Linux-IA64@linuxia64.org
  Alan> http://lists.linuxia64.org/lists/listinfo/linux-ia64


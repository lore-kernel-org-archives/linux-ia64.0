From: Alan Au <alanau@cse.unsw.EDU.AU>
Date: Thu, 10 Aug 2000 03:12:48 +0000
Subject: [Linux-ia64] arch/ia64/boot/bootloader.c
Message-Id: <marc-linux-ia64-105590678205302@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Can someone please tell me what the first itr mapping (the 1M page in
region 0) is for?  Thanks.


	/*
	 * Install a translation register that identity maps the
	 * kernel's 256MB page.
	 */
	ia64_clear_ic(flags);
	ia64_set_rr(          0, (0x1000 << 8) | (_PAGE_SIZE_1M << 2));
	ia64_set_rr(PAGE_OFFSET, (ia64_rid(0, PAGE_OFFSET) << 8) |
			(_PAGE_SIZE_256M << 2));
	ia64_srlz_d();
	ia64_itr(0x3, 0, 1024*1024,
		 pte_val(mk_pte_phys(1024*1024,
			__pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX))),
		 	_PAGE_SIZE_1M);
	ia64_itr(0x3, 1, PAGE_OFFSET,
		 pte_val(mk_pte_phys(0,
			__pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX))),
		 	_PAGE_SIZE_256M);



Alan
__________
alanau@cse.unsw.edu.au
School of Computer Science and Engineering
University of New South Wales




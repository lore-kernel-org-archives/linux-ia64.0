From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 31 May 2003 01:16:19 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.21-rc2-cset-1129 hugetlb, unwind fixes
Message-Id: <marc-linux-ia64-105590723706098@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706053@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706053@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 28 May 2003 17:17:24 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> arch/ia64/kernel/unwind.c: Only call get_scratch_regs() when
  Keith> pt is really needed.  The premature calls to
  Keith> get_scratch_regs() would pick up the wrong address for pt if
  Keith> the register was in switch_stack and pt_regs had not been
  Keith> reached yet, e.g. unw_access_ar(&info, UNW_AR_BSPSTORE,...)
  Keith> before pt_regs had been reached.

This looks fine to me.  Can you send me a 2.5 patch?

	--david


From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 07 Dec 2001 16:10:00 +0000
Subject: RE: [Linux-ia64] mprotect problem
Message-Id: <marc-linux-ia64-105590698805642@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805634@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805634@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 7 Dec 2001 06:53:14 -0800 , "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com> said:

  Jay> No, we haven't checked that this is not a page size or
  Jay> alignment issue.  The page size we get from getpagesize().

Can you find out *why* the later page faults occur?  Printing the ISR
should help.  The page fault handler does not (yet) setup si_isr in
the siginfo, but you could just hack
arch/ia64/mm/fault.c:ia64_do_page_fault() to print the ISR when you
detect the problematic case.

If you have a (small) test program that replicates the problem, I'd be
happy to look into it early next week.

	--david


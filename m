From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 May 2008 23:57:51 +0000
Subject: RE: [PATCH] ia64: fix interrupt masking for pending works on kernel leave
Message-Id: <1FE6DD409037234FAB833C420AA843EC014B94AB@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <48229532.7000809@jp.fujitsu.com>
In-Reply-To: <48229532.7000809@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> How about this patch as a draft?

Thank you.

Looks like a good start.  It is a bit hard to see the actual changes
amongst the formatting clean-up (are there any substantive changes to
perfmon.c at all?)

It builds cleanly, boots (on tiger_defconfig on 4xMontecito), doesn't
BUG when running "pstack $$" with CONFIG_DEBUG_SPINLOCK_SLEEP=y) and
otherwise seems to behaving normally (with the totally trivial amount
of testing that I have done so far).

-Tony

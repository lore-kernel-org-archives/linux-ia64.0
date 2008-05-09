From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 09 May 2008 01:48:23 +0000
Subject: Re: [PATCH] ia64: fix interrupt masking for pending works on kernel
Message-Id: <4823AD67.50900@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <48229532.7000809@jp.fujitsu.com>
In-Reply-To: <48229532.7000809@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> Looks like a good start.  It is a bit hard to see the actual changes
> amongst the formatting clean-up (are there any substantive changes to
> perfmon.c at all?)

I can make divided version, such as parts of substantive changes,
comments, and trivial cleanups.  Does it help you if I resend them?

> It builds cleanly, boots (on tiger_defconfig on 4xMontecito), doesn't
> BUG when running "pstack $$" with CONFIG_DEBUG_SPINLOCK_SLEEP=y) and
> otherwise seems to behaving normally (with the totally trivial amount
> of testing that I have done so far).

Thank you for testing.
I have run some test on applied kernel yesterday, and it looks good too.

Thanks,
H.Seto

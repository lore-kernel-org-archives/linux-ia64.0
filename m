From: alex_williamson@hp.com (Alex Williamson)
Date: Sun, 10 Aug 2003 05:28:23 +0000
Subject: Re: [patch] 2.4.21-ia64-030702 arch/ia64/kernel/mca.c
Message-Id: <marc-linux-ia64-106049336223079@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105909779318784@msgid-missing>
In-Reply-To: <marc-linux-ia64-105909779318784@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> The current kernel code does not conform to those specifications.
> SAL_GET_STATE_INFO_SIZE is supposed to be reentrant safe so it does not
> deadlock, but the Linux code uses SAL_CALL() with a spinlock that will
> hang for SAL_GET_STATE_INFO_SIZE during an existing SAL event.  I have
> hit this case.
> 
> The real fix is to change the non-conforming functions in sal.h to use
> SAL_CALL_NOLOCK.  But is it safe to do so, can all the platforms handle
> reentrant SAL calls?
> 
> I know that SGI SAL code is reentrant safe so I break any existing SAL
> lock, but only on SN2.  If the other platforms say that they are
> reentrant safe and the locking in sal.h is fixed then this sn2 specific
> patch is not required.  Until then, we need it in the kernel.

   See the modification I made to these for cmc/cpe polling.  I created
a new SAL call that runs with irqs enabled.  SAL_{GET,CLEAR}_STATE_INFO*
make use of them.  Nobody has spoken up yet about any platforms that
don't follow the SAL spec for these calls.  Bjorn accepted the changes,
but it doesn't look like they're in bk yet.  They're in 2.6.0-test3.
Does that eliminate this problem?

	Alex


From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 19 Dec 2003 18:07:04 +0000
Subject: RE: [patch] 2.6.0 MCA TLB error recovery
Message-Id: <marc-linux-ia64-107185743501256@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107181047921141@msgid-missing>
In-Reply-To: <marc-linux-ia64-107181047921141@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> >It looks like salinfo_log_wakeup() is called right before
> >ia64_log_print() ... so I'm not sure why the salinfo_decode
> >daemon kept on snoozing.  Keith: am I missing something obvious?
> 
> From the top of salinfo_log_wakeup()
> 
>  * ...  MCA and INIT events are
>  * not irq safe, do not call any routines that use spinlocks, 
> they may deadlock.

Okay ... that was pretty danged obvious!  Thanks for pointing
it out so gently :-)

> MCA and INIT records are noted but it is not safe to call up() from
> those interrupts, so the daemon cannot be woken.  This has not been a
> problem in the past because MCA and INIT were not recoverable, the
> records are picked up on the next boot.  Once my patches are 
> in David's
> tree, I will update salinfo to periodically check for any MCA or INIT
> records and kick the daemon.  There was no point before, I had no way
> of testing this case.

Sounds good.  Salinfo-0.4 is beautiful by the way.  Getting all the
bits decoded from processor state parameter and ipsr/xpsr etc. is great.

-Tony

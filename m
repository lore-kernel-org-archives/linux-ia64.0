From: Keith Owens <kaos@sgi.com>
Date: Fri, 19 Dec 2003 05:06:42 +0000
Subject: Re: [patch] 2.6.0 MCA TLB error recovery
Message-Id: <marc-linux-ia64-107181047921141@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 18 Dec 2003 15:37:09 -0800, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>It looks like salinfo_log_wakeup() is called right before
>ia64_log_print() ... so I'm not sure why the salinfo_decode
>daemon kept on snoozing.  Keith: am I missing something obvious?

From the top of salinfo_log_wakeup()

 * ...  MCA and INIT events are
 * not irq safe, do not call any routines that use spinlocks, they may deadlock.

MCA and INIT records are noted but it is not safe to call up() from
those interrupts, so the daemon cannot be woken.  This has not been a
problem in the past because MCA and INIT were not recoverable, the
records are picked up on the next boot.  Once my patches are in David's
tree, I will update salinfo to periodically check for any MCA or INIT
records and kick the daemon.  There was no point before, I had no way
of testing this case.


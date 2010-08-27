From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 27 Aug 2010 14:09:14 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201008271609.16099.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <20100827134802.GX18967@zorg.emea.sgi.com>
In-Reply-To: <20100827134802.GX18967@zorg.emea.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hedi Berriche <hedi@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Friday 27 of August 2010 15:48:02 Hedi Berriche wrote:
> On Fri, Aug 27, 2010 at 14:38 Petr Tesarik wrote:
> | Hi everybody,
> |
> | SGI has recently experienced failures with the new ticket spinlock
> | implementation. Hedi Berriche sent me a simple test case that can
> | trigger the failure on the siglock.
>
> One more fact, the problem was introduced by commit
>
>     commit 9d40ee200a527ce08ab8c793ba8ae3e242edbb0e
>     Author: Tony Luck <tony.luck@intel.com>
>     Date:   Wed Oct 7 10:54:19 2009 -0700
>
>         [IA64] Squeeze ticket locks back into 4 bytes.
>
> Reverting the patch makes the problem go away.
>
> IOW, and as far as testing shows, the first incarnation of the ticket locks
> implementation on IA64 (commit 2c8696), the one that used 8 bytes, does not
> exhibit this problem.

I wouldn't be so sure about it. Given that I have only observed the problem 
when the spinlock value wraps around, then an 8-byte spinlock might only need 
much more time to trigger the bug.

Just my two cents,
Petr Tesarik
L3 International
Novell, Inc.

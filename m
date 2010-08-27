From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 27 Aug 2010 14:40:48 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201008271640.49542.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <201008271609.16099.ptesarik@suse.cz> <20100827143135.GY18967@zorg.emea.sgi.com>
In-Reply-To: <20100827143135.GY18967@zorg.emea.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hedi Berriche <hedi@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Friday 27 of August 2010 16:31:35 Hedi Berriche wrote:
> On Fri, Aug 27, 2010 at 15:09 Petr Tesarik wrote:
> | On Friday 27 of August 2010 15:48:02 Hedi Berriche wrote:
> | > One more fact, the problem was introduced by commit
> | >
> | >     commit 9d40ee200a527ce08ab8c793ba8ae3e242edbb0e
> | >     Author: Tony Luck <tony.luck@intel.com>
> | >     Date:   Wed Oct 7 10:54:19 2009 -0700
> | >
> | >         [IA64] Squeeze ticket locks back into 4 bytes.
> | >
> | > Reverting the patch makes the problem go away.
> | >
> | > IOW, and as far as testing shows, the first incarnation of the ticket
> | > locks implementation on IA64 (commit 2c8696), the one that used 8
> | > bytes, does not exhibit this problem.
> |
> | I wouldn't be so sure about it. Given that I have only observed the
> | problem when the spinlock value wraps around, then an 8-byte spinlock
> | might only need much more time to trigger the bug.
>
> That's a possibility and that's why I said "as far as testing shows".
>
> That said, I'm letting my already over 36 hours run carry on chewing CPU
> time, and see if it will eventually trip the same problem seen with 4-byte
> ticket locks.

Hm, this doesn't sound like a viable approach. Since the siglock gets 
initialized to 0 when a new process is started, it may never actually wrap 
around.

I would rather attach a SystemTap probe somewhere during process fork and add 
a bias to the siglock. That should work fine. Let me knock up the SystemTap 
script...

Petr

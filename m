From: Chris Wedgwood <cw@f00f.org>
Date: Tue, 18 Jan 2005 07:08:52 +0000
Subject: Re: Horrible regression with -CURRENT from "Don't busy-lock-loop in preemptable spinlocks" patch
Message-Id: <20050118070852.GA26049@taniwha.stupidest.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050117055044.GA3514@taniwha.stupidest.org> <20050116230922.7274f9a2.akpm@osdl.org> <20050117143301.GA10341@elte.hu> <20050118014752.GA14709@cse.unsw.EDU.AU> <20050118042858.GD14709@cse.unsw.EDU.AU>
In-Reply-To: <20050118042858.GD14709@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, benh@kernel.crashing.org, linux-kernel@vger.kernel.org, Ia64 Linux <linux-ia64@vger.kernel.org>

On Tue, Jan 18, 2005 at 03:28:58PM +1100, Darren Williams wrote:

> On top of Ingo's patch I attempt a solution that failed:

> +#define read_is_locked(x)	(*(volatile int *) (x) > 0)
> +#define write_is_locked(x)	(*(volatile int *) (x) < 0)

how about something like:

#define read_is_locked(x)    (*(volatile int *) (x) != 0)
#define write_is_locked(x)   (*(volatile int *) (x) & (1<<31))

I'm not masking the write-bit for read_is_locked here, I'm not sure is
we should?


   --cw

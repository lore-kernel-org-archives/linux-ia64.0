From: Linus Torvalds <torvalds@osdl.org>
Date: Thu, 16 Dec 2004 00:41:08 +0000
Subject: Re: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <Pine.LNX.4.58.0412151634110.3279@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Thu, 16 Dec 2004, Nick Piggin wrote:
> 
> I think if there were *no* downsides to this patch, it would
> obviously make sense - because in that case it doesn't really matter
> whether the cache is heated by the fault handler or by the app
> itself... but it does have some downsides (complexity, memory
> bandwidth, cache degradation in the case of idle zeroing, less
> predictable performance).

The big downside I personally fear is that the added activity disturbs
other processes.

For example, even outside the obvious bus activity issues on SMP systems, 
things like idle loop exit latency and even just CPU power usage are 
things that makes me go "Hmmm.."

I don't dislike pre-zeroing per se, but I'm pretty strongly of the opinion
that it should be done not by the idle loop or any other very low-level
system process. I'd personally much prefer it donne at a somewhat higher
level, so that users can control it as part of system management, and so 
that it does not impact the _real_ idle loop.

So I'd much prefer a background "scrubd" or similar. 

			Linus

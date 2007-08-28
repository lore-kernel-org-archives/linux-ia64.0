From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 28 Aug 2007 19:42:45 +0000
Subject: Re: [PATCH] SLUB use cmpxchg_local
Message-Id: <Pine.LNX.4.64.0708281240260.16473@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827202203.GB5653@Krystal> <Pine.LNX.4.64.0708271324001.5884@schroedinger.engr.sgi.com>
 <20070827203913.GA7416@Krystal> <Pine.LNX.4.64.0708271401070.6435@schroedinger.engr.sgi.com>
 <20070827211003.GA10627@Krystal> <Pine.LNX.4.64.0708271421130.6566@schroedinger.engr.sgi.com>
 <20070827213845.GB9748@Krystal> <Pine.LNX.4.64.0708271510020.8783@schroedinger.engr.sgi.com>
 <20070827222715.GA16982@Krystal> <Pine.LNX.4.64.0708271811200.10344@schroedinger.engr.sgi.com>
 <20070828120756.GD12241@Krystal>
In-Reply-To: <20070828120756.GD12241@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mingo@redhat.com, linux-ia64@vger.kernel.org

On Tue, 28 Aug 2007, Mathieu Desnoyers wrote:

> Ok, I just had a look at ia64 instruction set, and I fear that cmpxchg
> must always come with the acquire or release semantic. Is there any
> cmpxchg equivalent on ia64 that would be acquire and release semantic
> free ? This implicit memory ordering in the instruction seems to be
> responsible for the slowdown.

No. There is no cmpxchg used in the patches that I tested. The slowdown 
seem to come from the need to serialize at barriers. Adding an interrupt
enable/disable in the middle of the hot path creates another serialization 
point.

> If such primitive does not exist, then we should think about an irq
> disable fallback for this local atomic operation. However, I would
> prefer to let the cmpxchg_local primitive be bound to the "slow"
> cmpxchg_acq and create something like _cmpxchg_local that would be
> interrupt-safe, but not reentrant wrt NMIs.

Ummm... That is what I did. See the included patch that you quoted. The 
measurements show that such a fallback is not preserving the performance 
on IA64.

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 17 May 2005 07:40:37 +0000
Subject: Re: [patch] improve SMP reschedule and idle routines
Message-Id: <20050517074037.GA13810@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <42881FE2.2000302@yahoo.com.au> <20050515.220455.59467677.davem@davemloft.net> <42899E78.6040306@yahoo.com.au>
In-Reply-To: <42899E78.6040306@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "David S. Miller" <davem@davemloft.net>, anton@samba.org, paulus@samba.org, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> David S. Miller wrote:
> 
> >I'll test this once you work out that obvious bug.
> >
> 
> David's got it tested and working. No difference in the tbench
> test reported for SPARC64.
> 
> Following are some numbers for a tbench 3.03 test: 1 client, 1 server
> in different configurations.
> 
> Xeon and G5 seem to be significantly improved on the order of 1-5%. I2 
> may be slightly down, but if it is significant I expect real world 
> workloads to be either not impacted, or hopefully some might see a 
> small improvement.
> [...]

> Unless anyone has an objection, I'm going to hack up untested 
> implementations for the rest of the architectures and see if Andrew 
> will put the patch in -mm for a while.

the patch looks good to me and builds / boots on my testsystems (x86, 
x64) too.

Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo

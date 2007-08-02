From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 02 Aug 2007 21:46:28 +0000
Subject: RE: ia64 mmu_gather question
Message-Id: <1186091188.5495.628.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186026055.5495.585.camel@localhost.localdomain>
In-Reply-To: <1186026055.5495.585.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2007-08-02 at 10:16 -0700, Luck, Tony wrote:
> 
> Montecito is SMT, and the threads do share the TLB resources in that
> there are a fixed number of TLB TC slots that are dynamically shared
> between threads. But entries in the TLB have their virtual addresses
> tagged
> with a thread identifier, so an entry inserted by one thread cannot
> be used by another thread.

Allright... that's a bit of a waste of TLB space though :-)

So I suspect at this stage that the race isn't affecting you. However,
it looks to me that you put the burden on the fairly hot TLB miss path
rather than on the much less hot invalidation path itself...

Cheers,
BenH


From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 15 Mar 2005 07:17:27 +0000
Subject: Re: bad pgd/pmd in latest BK on ia64
Message-Id: <1110871047.29138.92.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F031272AF@scsmsx401.amr.corp.intel.com>
	 <20050314143442.2ab086c9.davem@davemloft.net>
	 <20050314151142.716903cb.davem@davemloft.net>
	 <20050314153156.159d4bb3.davem@davemloft.net>
In-Reply-To: <20050314153156.159d4bb3.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>
Cc: tony.luck@intel.com, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, hugh@veritas.com

On Mon, 2005-03-14 at 15:31 -0800, David S. Miller wrote:
> On Mon, 14 Mar 2005 15:11:42 -0800
> "David S. Miller" <davem@davemloft.net> wrote:
> 
> > I therefore suspect the pgwalk patches.
> 
> I just noticed something else while reviewing this stuff.
> The PTRS_PER_PMD macros aren't used anymore, so my hacks
> to get 32-bit process VM operations optimized on sparc64
> aren't even being used any more, ho hum... :-)  There are
> better ways to do this.
> 
> (For the interested, see {REAL_}PTRS_PER_PMD in
>  include/asm-sparc64/pgtable.h)
> 
> Come to think of it, this may be related somehow to whatever
> is causing the problems.

That reminds me ... I still itend to toy with your old patches and add
some more abstract walkers & bitmap stuffs. Just no time at the moment. 

The main thing I want to change from your approach is instead of calling
a pte_work callback for every pte, call it for ranges of PTEs (that is
PTE pages most of the time). The goal here is to avoid the overhead of
the indirect function call (& additional stackframe junk etc...) on
every single PTE.

Ben.



From: "David S. Miller" <davem@davemloft.net>
Date: Mon, 14 Mar 2005 23:31:56 +0000
Subject: Re: bad pgd/pmd in latest BK on ia64
Message-Id: <20050314153156.159d4bb3.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F031272AF@scsmsx401.amr.corp.intel.com>
	<20050314143442.2ab086c9.davem@davemloft.net>
	<20050314151142.716903cb.davem@davemloft.net>
In-Reply-To: <20050314151142.716903cb.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>
Cc: tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, hugh@veritas.com

On Mon, 14 Mar 2005 15:11:42 -0800
"David S. Miller" <davem@davemloft.net> wrote:

> I therefore suspect the pgwalk patches.

I just noticed something else while reviewing this stuff.
The PTRS_PER_PMD macros aren't used anymore, so my hacks
to get 32-bit process VM operations optimized on sparc64
aren't even being used any more, ho hum... :-)  There are
better ways to do this.

(For the interested, see {REAL_}PTRS_PER_PMD in
 include/asm-sparc64/pgtable.h)

Come to think of it, this may be related somehow to whatever
is causing the problems.

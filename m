From: Horms <horms@verge.net.au>
Date: Tue, 20 Jun 2006 05:47:57 +0000
Subject: Re: [PATCH 1/2] ia64,kexec: refactor some mmu-related marcors to allow them to be reused by kexec
Message-Id: <20060620054757.E88A03402D@koto.vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060619082353.GA15635@verge.net.au>
In-Reply-To: <20060619082353.GA15635@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In article <20060620033113.GA18805@cse.unsw.EDU.AU> you wrote:
> On Mon, Jun 19, 2006 at 05:23:55PM +0900, Horms wrote:
>> +#define PTE_BITS		3
>> +#define MAPPED_SPACE_BITS	(3*(PAGE_SHIFT - PTE_BITS) + PAGE_SHIFT)
> 
> Can you fix this for 3/4 level page tables while you're at it?

Sure, could you give me a quick heads-up on what I should do to make
that happen.

-- 
Horms                                           http://www.vergenet.net/~horms/


From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 10 Dec 2004 05:19:56 +0000
Subject: Re: page fault scalability patch V12 [0/7]: Overview and	performance
Message-Id: <41B931FC.8040109@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0412091830580.17648-300000@localhost.localdomain>	 <41B92567.8070809@yahoo.com.au>  <41B92C11.80106@yahoo.com.au> <1102655177.22746.29.camel@gaston>
In-Reply-To: <1102655177.22746.29.camel@gaston>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

Benjamin Herrenschmidt wrote:
> On Fri, 2004-12-10 at 15:54 +1100, Nick Piggin wrote:
> 
>>Nick Piggin wrote:
>>
>>The page-freed-before-update_mmu_cache issue can be solved in that way,
>>not the set_pte and update_mmu_cache not performed under the same ptl
>>section issue that you raised.
> 
> 
> What is the problem with update_mmu_cache ? It doesn't need to be done
> in the same lock section since it's approx. equivalent to a HW fault,
> which doesn't take the ptl...
> 

I don't think a problem has been observed, I think Hugh was just raising
it as a general issue.

From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 19 Sep 2004 09:04:53 +0000
Subject: Re: page fault scalability patch V8: [2/7] avoid page_table_lock in handle_mm_fault
Message-Id: <20040919100453.A2596@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0409010938200.9907@schroedinger.engr.sgi.com> <1094080164.4025.17.camel@gaston> <Pine.LNX.4.58.0409012140440.23186@schroedinger.engr.sgi.com> <20040901215741.3538bbf4.davem@davemloft.net> <Pine.LNX.4.58.0409020920570.26893@schroedinger.engr.sgi.com> <20040902131057.0341e337.davem@davemloft.net> <Pine.LNX.4.58.0409021358540.28182@schroedinger.engr.sgi.com> <20040902140759.5f1003d5.davem@davemloft.net> <B6E8046E1E28D34EB815A11AC8CA312902CD3243@mtv-atc-605e--n.corp.sgi.com> <Pine.LNX.4.58.0409181625010.24054@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0409181625010.24054@schroedinger.engr.sgi.com>; from clameter@sgi.com on Sat, Sep 18, 2004 at 04:26:36PM -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, "David S. Miller" <davem@davemloft.net>, benh@kernel.crashing.org, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, ak@muc.de, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

> +	if (!ptep_cmpxchg(vma, addr, page_table, orig_entry, entry))
> +	{

wrong brace placement.

> +			if (!pmd_test_and_populate(mm, pmd, new))
> +				pte_free(new);
> +                        else

indentation using spaces instead of tabs

> +			pteval = ptep_xchg_flush(vma, address, pte, pgoff_to_pte(page->index));

please make sure lines are never longer than 80 characters

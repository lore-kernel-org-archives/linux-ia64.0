From: Andi Kleen <ak@suse.de>
Date: Thu, 05 Aug 2004 14:04:55 +0000
Subject: Re: Hugetlb demanding paging for -mm tree
Message-Id: <20040805140455.GE16763@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040805133637.GG14358@holomorphy.com> <200408051342.i75DgGY26555@unix-os.sc.intel.com>
In-Reply-To: <200408051342.i75DgGY26555@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'William Lee Irwin III' <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Seth, Rohit" <rohit.seth@intel.com>

On Thu, Aug 05, 2004 at 06:42:15AM -0700, Chen, Kenneth W wrote:
> +int hugetlb_acct_memory(long delta)
> +{
> +	atomic_add(delta, &hugetlbzone_resv);
> +	if (delta > 0 && atomic_read(&hugetlbzone_resv) >
> +			VMACCTPG(hugetlb_total_pages())) {
> +		atomic_add(-delta, &hugetlbzone_resv);
> +		return -ENOMEM;
> +	}
> +	return 0;

Wouldn't this be safer with a bit of locking? 
Even if the current code works lockless it would be more safer
for long term mainteance.

> +}
> +
> +struct file_region {
> +	struct list_head link;
> +	int from;
> +	int to;

Shouldn't these be long instead of int? 


> +	/* Check for and consume any regions we now overlap with. */

[...]

I remember writing very similar, but simpler code for NUMA API
regions. The PAT patches also have similar code. 
It's also tricky to get right.

Maybe it would be time to move variable length region list handling
into a nice library in lib/, so that it can be used by other users.

-Andi

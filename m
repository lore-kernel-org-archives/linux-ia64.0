From: Muli Ben-Yehuda <muli@il.ibm.com>
Date: Sun, 07 May 2006 08:54:58 +0000
Subject: Re: [PATCH 3/3] swiotlb: replace free array with bitmap
Message-Id: <20060507085458.GG6015@rhun.haifa.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060504210017.GE14361@us.ibm.com>
In-Reply-To: <20060504210017.GE14361@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jon Mason <jdmason@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, ak@suse.de, tony.luck@intel.com, linux-ia64@vger.kernel.org, mulix@mulix.org

On Thu, May 04, 2006 at 04:00:17PM -0500, Jon Mason wrote:

> +		index = find_next_zero_string(io_tlb_list, io_tlb_index,
> +				io_tlb_nslabs, nslots);
> +		if (index = ~0U) {
> +			index = find_next_zero_string(io_tlb_list, 0,
> +					io_tlb_nslabs, nslots);
> +			if (index = ~0U)
> +				return NULL;

If we run out of space in the bitmap we return here with the
io_tlb_lock held. Also, an informative message saying that we've run
out of space in the bitmap is probably a good idea.

Cheers,
Muli



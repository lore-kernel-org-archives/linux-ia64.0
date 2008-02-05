From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 05 Feb 2008 20:21:00 +0000
Subject: Re: [patch] Fix large MCA bootmem allocation
Message-Id: <200802051321.00331.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 05 February 2008 12:32:33 pm Russ Anderson wrote:
> +		if (first_time) {
> +			data = mca_bootmem();
> +			first_time = 0;
> +		} else
> +			data = page_address(alloc_pages_node(numa_node_id(),
> +					GFP_KERNEL, get_order(sz)));
> +	}

I assume this alloc_pages_node() path happens when a CPU is hot-added.
What happens if this alloc fails?

Bjorn

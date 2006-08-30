From: Kyle McMartin <kyle@parisc-linux.org>
Date: Wed, 30 Aug 2006 22:40:54 +0000
Subject: Re: [RFC][PATCH 7/9] parisc generic PAGE_SIZE
Message-Id: <20060830224054.GG3926@athena.road.mcmartin.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060830221604.E7320C0F@localhost.localdomain> <20060830221609.DA8E9016@localhost.localdomain>
In-Reply-To: <20060830221609.DA8E9016@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Aug 30, 2006 at 03:16:09PM -0700, Dave Hansen wrote:
> This is the parisc portion to convert it over to the generic PAGE_SIZE
> framework.
> 
<snip>
> Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

This looks pretty ok by me. I'll give it a test-build tonight.

Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>

> +config PARISC_LARGER_PAGE_SIZES
> +	def_bool y
>  	depends on PA8X00 && EXPERIMENTAL
>  

This should default to 'n' as I do not believe we yet have working >4K
pages yet.

Cheers! (Nice to see diffs with more '-' than '+' :)
	Kyle M.

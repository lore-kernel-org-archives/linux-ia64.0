From: Brian Gerst <bgerst@didntduck.org>
Date: Thu, 23 Dec 2004 20:08:14 +0000
Subject: Re: Prezeroing V2 [1/4]: __GFP_ZERO / clear_page() removal
Message-Id: <41CB25AE.6010109@didntduck.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com> <41C20E3E.3070209@yahoo.com.au> <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Christoph Lameter wrote:
> This patch introduces __GFP_ZERO as an additional gfp_mask element to allow
> to request zeroed pages from the page allocator.
> 
> o Modifies the page allocator so that it zeroes memory if __GFP_ZERO is set
> 
> o Replace all page zeroing after allocating pages by request for
>   zeroed pages.
> 
> o requires arch updates to clear_page in order to function properly.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 

> @@ -125,22 +125,19 @@
>  	int i;
>  	struct packet_data *pkt;
> 
> -	pkt = kmalloc(sizeof(struct packet_data), GFP_KERNEL);
> +	pkt = kmalloc(sizeof(struct packet_data), GFP_KERNEL|__GFP_ZERO);
>  	if (!pkt)
>  		goto no_pkt;
> -	memset(pkt, 0, sizeof(struct packet_data));
> 
>  	pkt->w_bio = pkt_bio_alloc(PACKET_MAX_SIZE);
>  	if (!pkt->w_bio)

This part is wrong.  kmalloc() uses the slab allocator instead of 
getting a full page.

--
				Brian Gerst

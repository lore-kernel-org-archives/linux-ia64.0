From: Andrew Morton <akpm@osdl.org>
Date: Thu, 05 Feb 2004 23:15:56 +0000
Subject: Re: [PATCH] memblks compile fixes
Message-Id: <20040205151556.157c88cb.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040205202503.GB6551@sgi.com>
In-Reply-To: <20040205202503.GB6551@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@sgi.com>
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Brown, Len" <len.brown@intel.com>

jbarnes@sgi.com (Jesse Barnes) wrote:
>
> Looks like Jes forgot missed some conversions in his NR_MEMBLKS removal
> patch.  Here's are the fixes to get ia64 going again.

It seems that Len has fixed one of these in the ACPI tree.

Len, were you planning on a merge soon?   (You should...)

> 
> === arch/ia64/kernel/acpi.c 1.60 vs edited ==> --- 1.60/arch/ia64/kernel/acpi.c	Tue Feb  3 21:35:17 2004
> +++ edited/arch/ia64/kernel/acpi.c	Thu Feb  5 11:46:50 2004
> @@ -395,7 +395,7 @@
>  	size = ma->length_hi;
>  	size = (size << 32) | ma->length_lo;
>  
> -	if (num_memblks >= NR_MEMBLKS) {
> +	if (num_node_memblks >= NR_NODE_MEMBLKS) {
>  		printk(KERN_ERR "Too many mem chunks in SRAT. Ignoring %ld MBytes at %lx\n",
>  		       size/(1024*1024), paddr);
>  		return;
> === arch/ia64/sn/kernel/setup.c 1.30 vs edited ==> --- 1.30/arch/ia64/sn/kernel/setup.c	Tue Feb  3 21:39:58 2004
> +++ edited/arch/ia64/sn/kernel/setup.c	Thu Feb  5 11:46:31 2004
> @@ -136,7 +136,7 @@
>  	int nid;
>  
>  	nid = pxm_to_nid_map[pxm];
> -	for (i = 0; i < num_memblks; i++) {
> +	for (i = 0; i < num_node_memblks; i++) {
>  		if (node_memblk[i].nid = nid) {
>  			return NASID_GET(node_memblk[i].start_paddr);
>  		}

From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 29 Jan 2004 23:09:34 +0000
Subject: Re: [PATCH] - Improve SN2 TLB flushing algorithms
Message-Id: <20040129230934.GA19273@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040128205912.GA27401@sgi.com>
In-Reply-To: <20040128205912.GA27401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 29, 2004 at 04:56:00PM -0600, Jack Steiner wrote:
> --- linux.base/./include/asm-ia64/mmu_context.h	Fri Jan  9 00:59:09 2004
> +++ linux/./include/asm-ia64/mmu_context.h	Thu Jan 29 13:08:11 2004

How did you generate this patch?  linux/./... seems like an odd path (it
should be applicable with patch -p1).

> @@ -21,6 +21,7 @@
>  
>  # ifndef __ASSEMBLY__
>  
> +#include <linux/config.h>
>  #include <linux/compiler.h>
>  #include <linux/percpu.h>
>  #include <linux/sched.h>

You can drop this hunk since you no longer refer to any CONFIG_*
variables.

> +	if (likely(i = 1 && lcpu = smp_processor_id())) {
> +		do {
> +			asm volatile ("ptc.l %0,%1" :: "r"(start), "r"(nbits<<2) : "memory");

Can you change this to ia64_ptcgl(start, nbits<<2) (I think that's the
right intrinsic).  I'm putting together a patch to convert all the
inline assembly in the sn2 code to use the intrinsics at David's
request, but it'll be easier if we don't add new stuff.

> -		for (cnode = 0; cnode < numnodes; cnode++) {
> -			if (is_headless_node(cnode))
> -				continue;
> -			if (cnode = mycnode) {
> +		for (i=0; i<nix; i++) {
> +			nasid = nasids[i];
> +			if (likely(nasid = mynasid)) {
>  				asm volatile ("ptc.ga %0,%1;;srlz.i;;" :: "r"(start), "r"(nbits<<2) : "memory");
>  			} else {
> -				nasid = cnodeid_to_nasid(cnode);
>  				ptc0 = CHANGE_NASID(nasid, ptc0);
>  				ptc1 = CHANGE_NASID(nasid, ptc1);
>  				pio_atomic_phys_write_mmrs(ptc0, data0, ptc1, data1);
> @@ -113,6 +156,7 @@

The above will no longer apply since that part has already been changed
to use ia64_ptcga(...).  Are you using the to-linus-2.5 BK tree?  If
not, that's probably easiest.

Thanks,
Jesse

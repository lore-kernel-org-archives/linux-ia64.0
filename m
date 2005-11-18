From: Robin Holt <holt@sgi.com>
Date: Fri, 18 Nov 2005 15:51:50 +0000
Subject: Re: [PATCH] - SN support for older versions of PROM
Message-Id: <20051118155150.GB14583@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051118151911.GA10918@sgi.com>
In-Reply-To: <20051118151911.GA10918@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack,

Is that really necessary?  The newer PROMs have other important
fixes.  They are available from supportfolio for free download
(Given with an annoying registration).  Why not just have people
upgrade.

I realize I am being a little unreasonable, but...

On Fri, Nov 18, 2005 at 09:19:11AM -0600, Jack Steiner wrote:
> 
> Add support for old versions of SN PROMs. Eventually this
> support will be deleted but it is useful right now to continue 
> supporting older PROMs.
> 
> (The support for older PROMs use to be in the tree. It was 
> deleted by accident).
> 
> 	Signed-off-by: Jack Steiner <steiner@sgi.com>
> 
> 
> Index: linux/include/asm/sn/sn_sal.h
> =================================> --- linux.orig/include/asm/sn/sn_sal.h	2005-11-17 22:38:30.741828181 -0600
> +++ linux/include/asm/sn/sn_sal.h	2005-11-18 09:06:12.328192683 -0600
> @@ -1018,6 +1018,24 @@ ia64_sn_get_sn_info(int fc, u8 *shubtype
>  	ret_stuff.v2 = 0;
>  	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_GET_SN_INFO, fc, 0, 0, 0, 0, 0, 0);
>  
> +/***** BEGIN HACK - temp til old proms no longer supported ********/
> +	if (ret_stuff.status = SALRET_NOT_IMPLEMENTED) {
> +		int nasid = get_sapicid() & 0xfff;;
> +#define SH_SHUB_ID_NODES_PER_BIT_MASK 0x001f000000000000UL                                               

Trailing whitespace!
> +#define SH_SHUB_ID_NODES_PER_BIT_SHFT 48                                                               

Trailing whitespace!
> +		if (shubtype) *shubtype = 0;
> +		if (nasid_bitmask) *nasid_bitmask = 0x7ff;
> +		if (nasid_shift) *nasid_shift = 38;
> +		if (systemsize) *systemsize = 10;
> +		if (sharing_domain_size) *sharing_domain_size = 8;
> +		if (partid) *partid = sn_partition_serial_number;
> +		if (coher) *coher = nasid >> 9;
> +		if (reg) *reg = (HUB_L((u64 *) LOCAL_MMR_ADDR(SH1_SHUB_ID)) & 

Trailing whitespace!
> +				 SH_SHUB_ID_NODES_PER_BIT_MASK) >> SH_SHUB_ID_NODES_PER_BIT_SHFT;
> +		return 0;
> +	}
> +/***** END HACK *******/
> +
>  	if (ret_stuff.status < 0)
>  		return ret_stuff.status;
>  


Thanks,
Robin

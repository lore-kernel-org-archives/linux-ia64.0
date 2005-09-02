From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 02 Sep 2005 19:57:06 +0000
Subject: Re: [PATCH] altix: Add volatile qualifiers in places where it seems necessary
Message-Id: <200509021957.j82Jv6Pm2373857@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
In-Reply-To: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mark Maule wrote:
> 
> Resend using accessors instead of volatile qualifiers per hch comments.  Added
> a __sn_rwq_relaxed() convenience macro for doing read/modify/write ops
> (e.g.  &=, |=).

Instead of passing in op codes, why not have two macros:  __sn_set_rwq_relaxed()
and __sn_clear_rwq_relaxed(), since the operation is either setting or clearing bits.


>  	if (pcibus_info) {
>  		switch (pcibus_info->pbi_bridge_type) {
>  		case PCIBR_BRIDGETYPE_TIOCP:
> -			ptr->tio.cp_control &= ~bits;
> +			__sn_rwq_relaxed(&ptr->tio.cp_control, &=, ~bits);

			__sn_clear_rwq_relaxed(&ptr->tio.cp_control, bits);

>  	tioca_base = (struct tioca *)common->ca_common.bs_base;
> -	ca_control1 = tioca_base->ca_control1;
> -	ca_control1 |= CA_AGP_FW_ENABLE;
> -	tioca_base->ca_control1 = ca_control1;
> +	__sn_rwq_relaxed(&tioca_base->ca_control1, |=, CA_AGP_FW_ENABLE);

	__sn_set_rwq_relaxed(&tioca_base->ca_control1, CA_AGP_FW_ENABLE);

>  /*
> + * Convenience macros for read/modify/write operations using above accessors
> + */
> +
> +#define __sn_rwq_relaxed(addr, op, val) \
> +	{uint64_t r = __sn_readq_relaxed(addr); r op (val); writeq(r, addr);}


#define __sn_set_rwq_relaxed(addr, val) \
	writeq((__sn_readq_relaxed(addr) | (val)), (addr))

#define __sn_clear_rwq_relaxed(addr, val) \
	writeq((__sn_readq_relaxed(addr) & ~(val)), (addr))



-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

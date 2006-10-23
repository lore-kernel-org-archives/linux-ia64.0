From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Mon, 23 Oct 2006 00:53:21 +0000
Subject: Re: [patch] MCA recovery: Montecito support
Message-Id: <453C1281.80106@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
In-Reply-To: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> +	/*
> +	 * Look through the cache checks for a valid target identifier
> +	 */
> +	for (i = 0; i < peidx_cache_check_num(peidx); i++) {
> +		smei = (sal_log_mod_error_info_t *)peidx_cache_check(peidx, i);
> +		if (smei->valid.target_identifier && smei->target_identifier)
> +			return smei->target_identifier;
> +	}

This says there would be more than 1 cache_check in the sal log.
I suppose it also means there would be more than 1 identifier.
Are there any reason why you don't handle identifiers other than
listed earliest?


Thanks,
H.Seto


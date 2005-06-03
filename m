From: Robin Holt <holt@sgi.com>
Date: Fri, 03 Jun 2005 13:58:53 +0000
Subject: Re: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <20050603135853.GA27820@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
In-Reply-To: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 03, 2005 at 07:25:28AM -0500, Dean Nelson wrote:
>  		for_each_online_node(cnode) {
>  			if (is_shub_1_1(cnodeid_to_nasid(cnode)))
> -				sn_hub_info->shub_1_1_found = 1;
> +				shub_1_1_found = 1;

This explains why XPC has been so troublesome to load on older systems.
Thanks Dean!

Tony, can this still get into 2.6.12?

Thanks,
Robin

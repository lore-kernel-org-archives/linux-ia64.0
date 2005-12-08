From: Andi Kleen <ak@suse.de>
Date: Thu, 08 Dec 2005 20:52:41 +0000
Subject: Re: [PATCH 3/3] Zone reclaim V3: Frequency of failed reclaim attempts
Message-Id: <20051208205241.GR11190@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051208203707.30456.57439.sendpatchset@schroedinger.engr.sgi.com> <20051208203717.30456.17434.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051208203717.30456.17434.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, steiner@sgi.com, linux-kernel@vger.kernel.org, ak@suse.de, Wu Fengguang <wfg@mail.ustc.edu.cn>

> +	if (zone->last_unsuccessful_zone_reclaim = get_jiffies_64())
> +		return 0;


and

>  
> +	unsigned long		last_unsuccessful_zone_reclaim;

For long you don't need get_jiffies_64. On 32bit it would be 32bit
anyways and on 64bit even normal jiffies is 64bit. So normal
jiffies would be suffice.

But I suspect it would be better to just merge the proper patch
with the full accounting instead of this kludge.

-Andi

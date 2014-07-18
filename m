From: Dave Hansen <dave.hansen@intel.com>
Date: Fri, 18 Jul 2014 15:00:43 +0000
Subject: Re: [PATCH 1/5] memory-hotplug: x86_64: suitable memory should go to ZONE_MOVABLE
Message-Id: <53C9369B.4070608@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1405670163-53747-1-git-send-email-wangnan0@huawei.com> <1405670163-53747-2-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1405670163-53747-2-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wang Nan <wangnan0@huawei.com>, Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Pei Feiyue <peifeiyue@huawei.com>, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/18/2014 12:55 AM, Wang Nan wrote:
> +	if (!zone_is_empty(movable_zone))
> +		if (zone_spans_pfn(movable_zone, start_pfn) ||
> +				(zone_end_pfn(movable_zone) <= start_pfn))
> +			zone = movable_zone;
> +

It's nice that you hit so many architectures, but is there a way to do
this that doesn't involve copying and pasting the same bit of code in to
each architecture?

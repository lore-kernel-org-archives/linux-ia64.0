From: Jay Lan <jlan@sgi.com>
Date: Tue, 08 Apr 2008 18:19:00 +0000
Subject: Re: [PATCH 1/2] ia64 kdump: add kdump_on_fatal_mca
Message-Id: <47FBB714.6050707@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47FAF533.8010707@jp.fujitsu.com>
In-Reply-To: <47FAF533.8010707@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>> I think kdump_on_fatal_mca should be set to 1 by default. Fatal
>> mca is exactly the case where we need a dump to analyze the problem.
> 
> I'm not so sure.  If the fatal MCA was caused by the s/w doing something
> wrong (e.g. accessing non-existant memory), then a dump is useful to find out
> what went wrong.
> 
> But if the MCA was caused by some h/w error (e.g. 2xECC bit error in kernel
> memory), then a dump won't help.
> 
> Perhaps the dump would help distinguish the s/w case from the h/w case?

With a dump, certainly it would be very clear, but that is not the
point.

When one puts aside a big chunk of memory for crashkernel. i think he
would like to get the dump when kernel crashes. Trying to recreate a
kernel crash on a large production system is expensive and  sometimes
not that readily reproducible.

Taking a dump on fatal MCA is the (default) bahavior today, isn't it?

- jay


> 
> -Tony
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


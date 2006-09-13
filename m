From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 13 Sep 2006 02:41:04 +0000
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
Message-Id: <45076FC0.7040507@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Martin Bligh wrote:

> What is really needed is to pass a physical address limit from the
> caller, together with a flag that says whether the memory needs to be
> mapped into the permanent kernel address space or not. The allocator
> then finds the set of zones that will fulfill this criteria.
> But I suspect this level of change will cause too many people to squeak
> loudly.

That's a good point and it will be something to keep in mind if we're
going to rework the allocator API.

Whether or not people will squeak, having callers say explicitly what
type of memory they want will be much easier to audit/verify and more
flexible in the long term (eg. allow a best effort allocation for odd
sized masks, perhaps).

Some sort of compatiblity (gfp flag -> address) mapping would be
required to support legacy allocator APIs, but I don't think that
would be a problem.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

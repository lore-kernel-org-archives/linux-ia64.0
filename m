From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 03 Feb 2005 21:40:27 +0000
Subject: RE: [rfc] generic allocator and mspec driver
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02D8CC03@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>Aha, I  wasn't aware of this, I thought the region registers worked
>like some giant TLB. I'll add a flush for the granule when it's pulled
>into the allocator.

No, the Alt-DTLB miss handler in ivt.S will blindly insert TLB
entries to fix any faults in region 6 or 7 ... giving the illusion
that it's all mapped 1:1, but actually only a few granules will
have mappings at any given time.

Maybe this handler should consult a "granule bitmap" before the
insert to make sure it doesn't compound an error from a wild access
by creating a TLB entry pointing at something that should be left
unmapped?  But that would be a big piece of memory for a sparse
machine like an Altix, and an extra memory load in the Alt-DTLB
path.

-Tony

From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 08 Mar 2005 23:56:24 +0000
Subject: RE: [Patch 0/3] Page table quicklist fixups Rev 3.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F030BBB94@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050303212359.GA732@lnx-holt.americas.sgi.com>
In-Reply-To: <20050303212359.GA732@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Tony, is this going to be acceptable?  Should it be the work queue or
>timer based?

The only downsides I see to Ken's suggestion are:

1) Will need extra hooks for hot plug cpu to start/stop new timer
when cpus are added/removed.  Some work is presumably needed here
anyway ... when a cpu is removed it's quicklist ought to be drained.

2) Opens a new question of whether 1 second is the right interval.
That may be a long time to wait for memory to be freed up.

-Tony

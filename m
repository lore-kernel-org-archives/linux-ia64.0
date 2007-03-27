From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 Mar 2007 18:42:52 +0000
Subject: RE: [PATCH] - Speed up boot - skip unnecessary clock calibration
Message-Id: <617E1C2C70743745A92448908E030B2A0148378E@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327132953.GA14401@sgi.com>
In-Reply-To: <20070327132953.GA14401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Skip clock calibration if cpu being brought online is exactly the same
> speed, stepping, etc., as the previous cpu. This significantly reduces
> the time to boot very large systems. 

Do we scan through the cpus in a way that makes this really useful I.e.
pounding through the cpus on a node - which are likely to be the
same - before going on to the next node?  Just looking at the
previous cpu won't help as much if we scan "breadth-first".

-Tony

From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 14 Apr 2006 17:39:52 +0000
Subject: RE: Setup an IA64 specific reclaim distance
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F063B58D8@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I am not familiar with that. Does the migration_cost take the 
> SLIT node distances into consideration?

migration_cost measures the actual node-node latency.  It gets
printed early in console output.  Since I only have one-node
boxes, I just see:

 migration_cost002

but I think on a multi-node box you'll get a string of numbers.

Ah, but looking at the code, I think I was mistaken ... it seems
to only know about distances between scheduler domains ... which
may or may not match with all the node information.  But it might
still be worth looking at to see whether it can be used, or can
be easily extended to be used.  A measured value is often better
than a static define that doesn't apply to all systems.

-Tony

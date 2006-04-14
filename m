From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 14 Apr 2006 16:18:51 +0000
Subject: RE: Setup an IA64 specific reclaim distance
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F063B5750@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> We found that on motherboard latencies are typically 1 to 1.4 of local memory
> access speed whereas multinode systems which benefit from zone reclaim have
> usually more than 1.5 times the latency of a local access.
> 
> Set the reclaim distance for IA64 to 1.5 times.

Does this really apply just to ia64 systems?  Or is the "20" value in
topology.h just wrong?

Is the right value for this any any way related to the "migration_cost"
that we spend many seconds of boot time computing?

-Tony

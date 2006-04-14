From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 14 Apr 2006 17:54:33 +0000
Subject: RE: Setup an IA64 specific reclaim distance
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F063B5924@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> RECLAIM_DISTANCE is compared against the largest node_distance() in the 
> system in order to make the decision if zone_reclaim should be enabled for 
> a system.
>
> node_distance() uses the SLIT talbe and is a dynamic value provided by 
> each system.

So node_distance is a reasonably meaningful number (providing that the
SLIT table is a accurate representation of reality ... about which we
are at the mercy of the f/w writers).

But I'm still trying to see why RECLAIM_DISTANCE would be different for
ia64 systems from other architectures.  If 15 is the right number for
ia64, why is 20 the right number for powerpc?  What if I have a 4-node
NUMA system with a NUMA factor of 1.6?  SLIT = 

10 16 16 16
16 10 16 16
16 16 10 16
16 16 16 10

Should I not use zone reclaim on this system?  But with factor=1.5
it would be OK?

-Tony

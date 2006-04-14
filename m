From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 14 Apr 2006 17:44:37 +0000
Subject: RE: Setup an IA64 specific reclaim distance
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F063B58F3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> No.  The migration_cost is an empirical runtime calculation that estimates the
> relative cost of migrating a task within each level of sched domain.  And even
> that is sometimes grossly inaccurate because only two arbitrary CPUs are
> chosen for this calculation within one sched domain at each level, thus
> assuming that the migration_cost is the same between any and all two CPUs in
> that sched domain, and that all the sched domains for a given level exhibit
> equivalent migration_cost behavior.

Sounds like this code needs to see if there is a SLIT table, and if there is
use it to decide which cpus to use, rather than picking arbitrarily.

-Tony

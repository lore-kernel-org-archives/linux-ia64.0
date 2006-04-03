From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 03 Apr 2006 15:57:06 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F061E0C10@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> It is very much curious having so few dirty and i-access traps...

Your data collection code has races (ld8, add, st8 on one cpu can
race with another cpu doing the same).  So you'll undercount whenever
a race happens.

Perhaps you should use per-cpu counters to collect the values, and
then sum for each cpu in the syscall() before reporting to the user?

-Tony

From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 Jul 2006 23:48:37 +0000
Subject: NUMA but not SMP
Message-Id: <617E1C2C70743745A92448908E030B2A30031D@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

IA64 allows NUMA to be set without SMP ... in fact you
end up with this when trying to build a "generic UP" kernel
since CONFIG_IA64_GENERIC selects NUMA, and won't let you
unselect it.

Suddenly this is a problem.  Generic UP kernel fails to build
with an "Undefined: __inc_zone_state", which shows up because
the __inc_zone_state function is defined inside some #if SMP
code, but used inside some #if NUMA code in mm/vmstat.c

What does NUMA && !SMP mean?  Should selecting NUMA force SMP?

-Tony

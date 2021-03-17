From: Valentin Schneider <valentin.schneider@arm.com>
Date: Wed, 17 Mar 2021 20:56:12 +0000
Subject: Re: [PATCH 0/1] sched/topology: NUMA distance deduplication
Message-Id: <87wnu5pkib.mognet@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <255d6b5d-194e-eb0e-ecdd-97477a534441@physik.fu-berlin.de> <8735wtr2ro.mognet@arm.com> <cf4d7277-54a0-8bc7-60fb-9b2f6befb511@physik.fu-berlin.de> <87zgz1pmx4.mognet@arm.com>
In-Reply-To: <87zgz1pmx4.mognet@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Sergei Trofimovich <slyfox@gentoo.org>, debian-ia64 <debian-ia64@lists.debian.org>

On 17/03/21 20:04, Valentin Schneider wrote:
> Technically it *is* coping with it, it's just dumping the entire NUMA
> distance matrix in the process... Let me see if I can't figure out why your
> system doesn't end up with nr_node_ids=1.
>

Does the below
a) compile
b) do anything?

From what I could gather, nothing actually tickles the possible map for
ia64. The standard pattern seems to be

        node_possible_map = numa_nodes_parsed;

but here at a quick glance it seems it's online or nothing, so that's what
I went for.

HTH.

---
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index a5636524af76..e2af6b172200 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -446,7 +446,8 @@ void __init acpi_numa_fixup(void)
 	if (srat_num_cpus = 0) {
 		node_set_online(0);
 		node_cpuid[0].phys_id = hard_smp_processor_id();
-		return;
+		slit_distance(0, 0) = LOCAL_DISTANCE;
+		goto out;
 	}
 
 	/*
@@ -489,7 +490,7 @@ void __init acpi_numa_fixup(void)
 			for (j = 0; j < MAX_NUMNODES; j++)
 				slit_distance(i, j) = i = j ?
 					LOCAL_DISTANCE : REMOTE_DISTANCE;
-		return;
+		goto out;
 	}
 
 	memset(numa_slit, -1, sizeof(numa_slit));
@@ -514,6 +515,8 @@ void __init acpi_numa_fixup(void)
 		printk("\n");
 	}
 #endif
+out:
+	node_possible_map = node_online_map;
 }
 #endif				/* CONFIG_ACPI_NUMA */
 

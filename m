From: Xavier Bru <xavier.bru@bull.net>
Date: Fri, 27 May 2005 15:57:53 +0000
Subject: ia64 sched-domains initialisation
Message-Id: <42974381.9080000@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010504060109050306080207"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010504060109050306080207
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"; format="flowed"

Hello Jesse and all,

There is curently an issue with sched domain initialisations on some=20
Numa platforms:

Current ia64 implementation provides a SD_NODES_PER_DOMAIN #define that=20
is used to build a top level domain when there are 2 levels of Numa in=20
the platform.
This value is different on some platforms: for example a 2 modules * 4=20
nodes * 4 cpus platform should use SD_NODES_PER_DOMAIN =3D 4 instead of=20
the current value 6.
It is easy to provide the SD_NODES_PER_DOMAIN as a config parameter or=20
boot parameter.
But, even with the correct value for the platform, there are side=20
effects when the configuration has some disymetry.
For example: with SD_NODES_PER_DOMAIN=3D4:
    .  on a 1 module of 4 nodes * 4 cpus where there is a missing cpu=20
(then a 3 nodes * 4 cpus plus a 1 node * 3 cpus), sched_domain=20
initialisation tries to build a top-level domain for the node that=20
contains 3 cpus and we get an "ERROR: domain->cpu_power not set" error.
    . on a 2 modules * 4 nodes configuration with 1 node missing (then a=20
4 * nodes module and a 3 * nodes module), there is 1 node that is part=20
of both node domains.
An alternative is setting SD_NODES_PER_DOMAIN to the maximum number of=20
nodes (thus loosing the ability to have 2 levels of sched domains to=20
take in account the Numa topology).
An other alternative is using the node_distance() that comes from the=20
SLIT to build the sched domains instead of using
SD_NODES_PER_DOMAIN on the platform.
The following patch sets SD_NODES_PER_DOMAIN as a config/boot parameter,=20
and when the value is 0 uses the node_distance to build the sched domains.

This patch allows configuring the sched-domains based on the SLIT table=20
on ia64 platforms.
It should allow having disymetric configurations like having different=20
numbers of cpus per node or missing nodes
when a top level domain is used.
Current limitation is 2 level Numa.

diff --exclude-from /home17/xb/proc/patch.exclude -Nurp=20
linux-2.6.11-kgdbr/arch/ia64/Kconfig linux-2.6.11-kgdb/arch/ia64/Kconfig
--- linux-2.6.11-kgdbr/arch/ia64/Kconfig    2005-03-02=20
08:38:26.000000000 +0100
+++ linux-2.6.11-kgdb/arch/ia64/Kconfig    2005-05-26 13:52:10.362718582=20
+0200
@@ -174,6 +174,18 @@ config NUMA
       Access).  This option is for configuring high-end multiprocessor
       server systems.  If in doubt, say N.
=20
+config SD_NODES_PER_DOMAIN
+    int "Number of nodes per base sched_domains"
+    default "6"
+    help
+      Number of nodes per base sched_domains.
+
+      Should be 6 for SGI platforms.
+      Should be 0 for platforms that rely on SLIT table
+      to build the sched_domains (Eg: Bull Novascale)
+      This value can be provided at boot time using the
+      sd_nodes_per_domain boot parameter.
+      =20
 config VIRTUAL_MEM_MAP
     bool "Virtual mem map"
     default y if !IA64_HP_SIM
diff --exclude-from /home17/xb/proc/patch.exclude -Nurp=20
linux-2.6.11-kgdbr/arch/ia64/kernel/domain.c=20
linux-2.6.11-kgdb/arch/ia64/kernel/domain.c
--- linux-2.6.11-kgdbr/arch/ia64/kernel/domain.c    2005-03-02=20
08:38:33.000000000 +0100
+++ linux-2.6.11-kgdb/arch/ia64/kernel/domain.c    2005-05-26=20
16:11:49.299139378 +0200
@@ -14,20 +14,29 @@
 #include <linux/topology.h>
 #include <linux/nodemask.h>
=20
-#define SD_NODES_PER_DOMAIN 6
-
 #ifdef CONFIG_NUMA
+
+static int numa_lvls =3D -1;
+static int sd_nodes_per_domain =3D CONFIG_SD_NODES_PER_DOMAIN;
+
+static int __init set_sd_nodes_per_domain(char *str)
+{
+    get_option(&str, &sd_nodes_per_domain);
+    return 1;
+}
+__setup("sd_nodes_per_domain=3D", set_sd_nodes_per_domain);
+
 /**
  * find_next_best_node - find the next node to include in a sched_domain
  * @node: node whose sched_domain we're building
  * @used_nodes: nodes already in the sched_domain
- *
+ * @dist: distance to node
  * Find the next node to include in a given scheduling domain.  Simply
  * finds the closest node not already in the @used_nodes map.
  *
  * Should use nodemask_t.
  */
-static int __devinit find_next_best_node(int node, unsigned long=20
*used_nodes)
+static int __devinit find_next_best_node(int node, unsigned long=20
*used_nodes, int *dist)
 {
     int i, n, val, min_val, best_node =3D 0;
=20
@@ -54,6 +63,7 @@ static int __devinit find_next_best_node
     }
=20
     set_bit(best_node, used_nodes);
+    *dist =3D min_val;
     return best_node;
 }
=20
@@ -70,6 +80,7 @@ static cpumask_t __devinit sched_domain_
 {
     int i;
     cpumask_t span, nodemask;
+    int dist_min =3D INT_MAX;
     DECLARE_BITMAP(used_nodes, MAX_NUMNODES);
=20
     cpus_clear(span);
@@ -79,8 +90,13 @@ static cpumask_t __devinit sched_domain_
     cpus_or(span, span, nodemask);
     set_bit(node, used_nodes);
=20
-    for (i =3D 1; i < SD_NODES_PER_DOMAIN; i++) {
-        int next_node =3D find_next_best_node(node, used_nodes);
+    for (i =3D 1; i < sd_nodes_per_domain; i++) {
+        int dist;
+        int next_node =3D find_next_best_node(node, used_nodes, &dist);
+        if ((numa_lvls >=3D 0) && (dist > dist_min))
+            /* keep only nearest nodes when building sched domains=20
based on node distance */
+            break;
+        dist_min =3D dist;
         nodemask =3D node_to_cpumask(next_node);
         cpus_or(span, span, nodemask);
     }
@@ -132,6 +148,26 @@ static int __devinit cpu_to_allnodes_gro
 #endif
=20
 /*
+ *    returns number of numa levels based on node_distance()
+ */
+
+static int find_numa_lvls(void)
+{
+    int i, j, dist[MAX_NUMNODES]=3D{0}, numa_lvls=3D0;
+  =20
+    for (i =3D 0; i < MAX_NUMNODES; i++) {
+        if (!nr_cpus_node(i))
+            continue;
+        for (j =3D 0; j < MAX_NUMNODES; j++)
+            if (node_distance(0,i) =3D=3D dist[j])
+                break;
+        if (j =3D=3D MAX_NUMNODES)
+            dist[numa_lvls++] =3D node_distance(0,i);
+    }
+    return numa_lvls - 1;
+}
+
+/*
  * Set up scheduler domains and groups.  Callers must hold the hotplug=20
lock.
  */
 void __devinit arch_init_sched_domains(void)
@@ -139,6 +175,19 @@ void __devinit arch_init_sched_domains(v
     int i;
     cpumask_t cpu_default_map;
=20
+    if (sd_nodes_per_domain =3D=3D 0) {
+  =20
+        /* sched domain configuration relies on node distances */
+
+        numa_lvls =3D find_numa_lvls();
+        sd_nodes_per_domain =3D MAX_NUMNODES;
+
+        /* Currently 2-level numa maximum support */
+
+        if (numa_lvls > 2)
+            BUG();
+    }
+
     /*
      * Setup mask for cpus without special case scheduling requirements.
      * For now this just excludes isolated cpus, but could be used to
@@ -158,8 +207,8 @@ void __devinit arch_init_sched_domains(v
         cpus_and(nodemask, nodemask, cpu_default_map);
=20
 #ifdef CONFIG_NUMA
-        if (num_online_cpus()
-                > SD_NODES_PER_DOMAIN*cpus_weight(nodemask)) {
+         if ((numa_lvls =3D=3D 2) || (num_online_cpus()
+                 > sd_nodes_per_domain*cpus_weight(nodemask))) {
             sd =3D &per_cpu(allnodes_domains, i);
             *sd =3D SD_ALLNODES_INIT;
             sd->span =3D cpu_default_map;

--=20

	Sinc=E8res salutations.


--------------010504060109050306080207
Content-Transfer-Encoding: 7bit
Content-Type: text/x-vcard; charset=utf-8;
 name="xavier.bru.vcf"
Content-Disposition: attachment;
 filename="xavier.bru.vcf"

begin:vcard
fn:Xavier Bru
n:Bru;Xavier
adr:;;1 rue de Provence, BP 208;Echirolles;;38432 Cedex;France
email;internet:Xavier.Bru@bull.net
title:BULL/DT/Open Software/linux/ia64
tel;work:+33 (0)4 76 29 77 45
tel;fax:+33 (0)4 76 29 77 70
x-mozilla-html:TRUE
url:http://www-frec.bull.fr
version:2.1
end:vcard


--------------010504060109050306080207--

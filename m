From: Xavier Bru <xavier.bru@bull.net>
Date: Wed, 16 Feb 2005 17:17:07 +0000
Subject: Allow to change SD_NODES_PER_DOMAIN at configuration or boot time
Message-Id: <42138013.3060909@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000904010200040201000702"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------000904010200040201000702
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"; format="flowed"

Hello Nick and all,
I remember this was discussed some months ago, but it still seems that=20
on 2.6.10, SD_NODES_PER_DOMAIN is statically defined to value 6.
This is not what is expected on Bull ia64 platforms, based on modules of=20
4 bricks of 4 cpus each.
Using the cpu hot-plug mechanism to re-define dynamically the=20
sched-domains looks heavy (please correct me if I am wrong).
Hereafter a trivial patch that allows to setup SD_NODES_PER_DOMAIN at=20
configuration time or at boot time.
Boot time parameter should be helpfull, as on 32*ways machine based on 2=20
modules of 4 bricks of 4 cpus each, it allows to build either 1=20
(SD_NODES_PER_DOMAIN=3D8) or 2 (SD_NODES_PER_DOMAIN=3D4) NUMA sched-domain =

levels.
Thanks in advance for your comments.

diff --exclude-from /home15/xb/proc/patch.exclude -Nurp=20
/tmp/linux-2.6.10/arch/ia64/Kconfig linux-2.6.10/arch/ia64/Kconfig
--- /tmp/linux-2.6.10/arch/ia64/Kconfig    2004-12-24 22:35:29.000000000=20
+0100
+++ linux-2.6.10/arch/ia64/Kconfig    2005-02-15 17:07:46.741070673 +0100
@@ -168,6 +168,17 @@ config NUMA
       Access).  This option is for configuring high-end multiprocessor
       server systems.  If in doubt, say N.
=20
+config SD_NODES_PER_DOMAIN
+    int "Number of nodes per base sched_domains"
+    default "4" if IA64_DIG
+    default "6"
+    help
+      Number of nodes per base sched_domains.
+      Should be 6 for SGI platforms.
+      Should be 4 for DIG platforms.
+      This value can be provided at boot time using the sd_nodes_per_domain
+      boot parameter.
+      =20
 config VIRTUAL_MEM_MAP
     bool "Virtual mem map"
     default y if !IA64_HP_SIM
diff --exclude-from /home15/xb/proc/patch.exclude -Nurp=20
/tmp/linux-2.6.10/arch/ia64/kernel/domain.c=20
linux-2.6.10/arch/ia64/kernel/domain.c
--- /tmp/linux-2.6.10/arch/ia64/kernel/domain.c    2004-12-24=20
22:35:40.000000000 +0100
+++ linux-2.6.10/arch/ia64/kernel/domain.c    2005-02-15=20
15:04:08.964794354 +0100
@@ -13,7 +13,14 @@
 #include <linux/init.h>
 #include <linux/topology.h>
=20
-#define SD_NODES_PER_DOMAIN 6
+int sd_nodes_per_domain =3D CONFIG_SD_NODES_PER_DOMAIN;
+
+static int __init set_sd_nodes_per_domain(char *str)
+{
+    get_option(&str, &sd_nodes_per_domain);
+    return 1;
+}
+__setup("sd_nodes_per_domain=3D", set_sd_nodes_per_domain);
=20
 #ifdef CONFIG_NUMA
 /**
@@ -78,7 +85,7 @@ static cpumask_t __devinit sched_domain_
     cpus_or(span, span, nodemask);
     set_bit(node, used_nodes);
=20
-    for (i =3D 1; i < SD_NODES_PER_DOMAIN; i++) {
+    for (i =3D 1; i < sd_nodes_per_domain; i++) {
         int next_node =3D find_next_best_node(node, used_nodes);
         nodemask =3D node_to_cpumask(next_node);
         cpus_or(span, span, nodemask);
@@ -159,7 +166,7 @@ void __devinit arch_init_sched_domains(v
=20
 #ifdef CONFIG_NUMA
         if (num_online_cpus()
-                > SD_NODES_PER_DOMAIN*cpus_weight(nodemask)) {
+                > sd_nodes_per_domain*cpus_weight(nodemask)) {
             sd =3D &per_cpu(allnodes_domains, i);
             *sd =3D SD_ALLNODES_INIT;
             sd->span =3D cpu_default_map;

--=20

	Sinc=E8res salutations.


--------------000904010200040201000702
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


--------------000904010200040201000702--

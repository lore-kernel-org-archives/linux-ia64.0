From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 22 Nov 2004 16:54:58 +0000
Subject: [PATCH] ia64 iosapic: ignore offline CPUs when routing interrupts
Message-Id: <200411220954.59228.bjorn.helgaas@hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_jnhoBbgpQgo0rqo"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_jnhoBbgpQgo0rqo
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Ignore offline CPUs when registering IOSAPIC interrupts.  We previously
directed interrupts even to offline CPUs, which means that if you have some
unused CPUs (e.g., you used "maxcpus="), some interrupts won't work.

This really hurts because distro installs typically use "maxcpus=1".

--Boundary-00=_jnhoBbgpQgo0rqo
Content-Type: text/x-diff;
  charset="us-ascii";
  name="diffs"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="diffs"

Ignore offline CPUs when registering IOSAPIC interrupts.  We previously
directed interrupts even to offline CPUs, which means that if you have some
unused CPUs (e.g., you used "maxcpus="), some interrupts won't work.

This really hurts because distro installs typically use "maxcpus=1".

Patch by Alex Williamson.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

===== arch/ia64/kernel/iosapic.c 1.48 vs edited =====
--- 1.48/arch/ia64/kernel/iosapic.c	2004-10-05 12:30:39 -06:00
+++ edited/arch/ia64/kernel/iosapic.c	2004-11-21 20:34:57 -07:00
@@ -521,7 +521,12 @@
 			goto skip_numa_setup;
 
 		cpu_mask = node_to_cpumask(iosapic_lists[iosapic_index].node);
-		
+
+		for_each_cpu_mask(numa_cpu, cpu_mask) {
+			if (!cpu_online(numa_cpu))
+				cpu_clear(numa_cpu, cpu_mask);
+		}
+
 		num_cpus = cpus_weight(cpu_mask);
 
 		if (!num_cpus)

--Boundary-00=_jnhoBbgpQgo0rqo--

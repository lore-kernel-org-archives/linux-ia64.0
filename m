From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 04 Aug 2005 04:46:15 +0000
Subject: Defconfigs
Message-Id: <17137.40343.17846.811617@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Given that we have all those defconfigs, it'd be nice to know what
they're all for.  Appended please find a patch to add a documentation
file to explain them.  As I'm not really sure what they all really
*are* for, this is just a starting point.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

diff --new-file -u -r linux-2.6-unchanged/Documentation/ia64/defconfigs linux-2.6-import/Documentation/ia64/defconfigs
--- linux-2.6-unchanged/Documentation/ia64/defconfigs	1970-01-01 10:00:00.000000000 +1000
+++ linux-2.6-import/Documentation/ia64/defconfigs	2005-08-04 14:01:56.388975668 +1000
@@ -0,0 +1,15 @@
+The following `canned' configurations are available.  These often get
+quite out of date, but are a good starting point:
+
+In arch/ia64/
+  defconfig --- a `Generic' configuration that should boot on
+	        many IA64 platforms.  It does not boot on the
+		HP simulator.
+  configs/bigsur_defconfig --- i2000 and similar Itanium-1 machines.
+  configs/sim_defconfig --- for the HP `Ski' simulator.
+  configs/sn2_defconfig --- for SGI Altix machines.
+  configs/tiger_defconfig --- for many SMP Itanium-2 machines, other
+			      than the Altix.
+  configs/zx1_defconfig --- for machines based on HP's ZX1 chipset,
+			    such as the zx2000 workstation.
+

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*

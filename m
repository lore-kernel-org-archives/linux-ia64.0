From: Venki Pallipadi <venkatesh.pallipadi@intel.com>
Date: Fri, 06 Apr 2007 17:04:49 +0000
Subject: [PATCH] ia64: Fix CPU freq displayed in /proc/cpuinfo
Message-Id: <20070406170449.GA21441@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org



My patch: git commit=95235ca2c20ac0b31a8eb39e2d599bcc3e9c9a10 introduced a =
bug
in IA64 cpuinfo output.

Patch changed the proc_freq from 1HZ resolution to 1KHz resolution, but left
format string unchanged at " %lu.%06lu". Below is the fix.

Thanks to Bjorn for catching this.

Signed-off-by: Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>

Index: new/arch/ia64/kernel/setup.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- new.orig/arch/ia64/kernel/setup.c	2007-04-02 09=
:42:37.000000000 -0700
+++ new/arch/ia64/kernel/setup.c	2007-04-06 08:31:23.000000000 -0700
@@ -639,7 +639,7 @@
 		   "features   : %s\n"
 		   "cpu number : %lu\n"
 		   "cpu regs   : %u\n"
-		   "cpu MHz    : %lu.%06lu\n"
+		   "cpu MHz    : %lu.%03lu\n"
 		   "itc MHz    : %lu.%06lu\n"
 		   "BogoMIPS   : %lu.%02lu\n",
 		   cpunum, c->vendor, c->family, c->model,

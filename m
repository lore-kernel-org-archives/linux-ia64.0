From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 13 Dec 2001 03:29:09 +0000
Subject: [Linux-ia64] Re: We're down to just 32 missing Configure.help symbols
Message-Id: <marc-linux-ia64-105590698805690@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Dec 12, 2001 at 09:33:07PM -0500, Eric S. Raymond wrote:
> We're down to just 32 missing Configure.help entries, thanks to excellent
> cooperation from the ARM developers and a siege of rooting through kernel 
> sources by yours truly.  That's a big improvement from 96 last week.

Here's a patch for a couple of the missing IA64 entries, hope it's
helpful.

Jesse


diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.16/Documentation/Configure.help linux-2.4.16-confighelp/Documentation/Configure.help
--- linux-2.4.16/Documentation/Configure.help	Thu Nov 22 10:52:44 2001
+++ linux-2.4.16-confighelp/Documentation/Configure.help	Wed Dec 12 19:24:14 2001
@@ -15635,6 +15635,23 @@
 
   If unsure, say N.
 
+Support for SGI L1 system controllers
+CONFIG_SERIAL_SGI_L1_PROTOCOL
+  Saying Y here will build support for SGI L1 system controllers.
+
+  The L1 system controller is used as a console device as well as
+  for various system management tasks (e.g. power on/off, reset,
+  fan control, etc.).  You'll want to say Y here unless you have
+  special needs.
+
+Enable llsc cache coherency test
+CONFIG_IA64_SGI_AUTOTEST
+  Build a kernel used for hardware validation. If you include the
+  keyword "autotest" on the boot command line, the kernel does NOT boot.
+  Instead, it starts all cpus and runs cache coherency tests instead.
+
+  If unsure, say N.
+
 Support for PowerMac serial ports
 CONFIG_MAC_SERIAL
   If you have Macintosh style serial ports (8 pin mini-DIN), say Y


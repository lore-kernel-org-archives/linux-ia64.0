From: Paul Jackson <pj@sgi.com>
Date: Sun, 04 Jul 2004 02:19:06 +0000
Subject: [patch] Fix ia64 UPF_RESOURCES pcdp.c 2.6.7-mm5 build
Message-Id: <20040704021907.32029.98969.47514@sam.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org, David Mosberger <davidm@hpl.hp.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, bjorn.helgaas@hp.com
Cc: Matt Tolentino <matthew.e.tolentino@intel.com>, Russell King <rmk@arm.linux.org.uk>, Paul Jackson <pj@sgi.com>

It looks like someone removed UPF_RESOURCES in remove-upf_resources.patch
in parallel with someone adding drivers/firmware/pcdp.c that references
UPF_RESOURCES.

In any event, trying to build a defconfig ia64 2.6.7-mm5 (which includes
CONFIG_SERIAL_8250=y in the .config) fails with:

================  CC      drivers/firmware/pcdp.o
drivers/firmware/pcdp.c: In function `setup_serial_console':
drivers/firmware/pcdp.c:100: error: `UPF_RESOURCES' undeclared (first use in this function)
================
The following patch fixes this build error.

Someone with a certified clue needs to sign off on this.
I'm just typing blindly.

Signed-off-by: Paul Jackson <pj@sgi.com>

Index: 267mm5cpusetv4ia64/drivers/firmware/pcdp.c
=================================--- 267mm5cpusetv4ia64.orig/drivers/firmware/pcdp.c	2004-07-03 16:52:20.000000000 -0700
+++ 267mm5cpusetv4ia64/drivers/firmware/pcdp.c	2004-07-03 16:52:34.000000000 -0700
@@ -97,7 +97,7 @@ setup_serial_console(int rev, struct pcd
 		default:  port.type = PORT_UNKNOWN; break;
 	}
 
-	port.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF | UPF_RESOURCES;
+	port.flags = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF;
 
 	if (uart_irq_supported(rev, uart)) {
 		port.irq = acpi_register_gsi(uart->gsi,

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373

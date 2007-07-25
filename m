From: Horms <horms@verge.net.au>
Date: Wed, 25 Jul 2007 07:06:25 +0000
Subject: [IA64] Ensure that machvec is set up takes place before serial console
Message-Id: <20070725070904.285EE4F892@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Short Description

Parse the machvec command line option outside of the early_param()
so that ia64_mv is set before any console intialisation that
may result from early_param parsing.

Long Description

18a8bd949d6adb311ea816125ff65050df1f3f6e appears to have caused
a regression in the serial console for ia64. I have observed the
problem on Intel Tiger2 and HP RX2620 when the console or early
cons option is specified.

For reference

Tiger2: console=uart,io,0x2f8,115200n8
RX2620: console=uart,mmio,0xff5e0000,115200n8

uart may also be uart8250, it makes no difference with regards to
this problem. console may be earlycons, that also makes no
difference as 18a8bd949d6adb311ea816125ff65050df1f3f6e handles
both options the almost the same way.

On the RX2620 a work around is to omit the console and earlycons
parameters all together, as the code in efi_setup_pcdp_console() will
autodetect the console and set it up correctly.


I believe that the problem is as follows:

After 18a8bd949d6adb311ea816125ff65050df1f3f6e, both the console
and earlycons options are handled by early_param, using the callback
setup_early_serial8250_console().

On ia64, for the hardware that I am observing this problem on
(HP RX2620 and Intel Tiger2), I believe that I am seeing the
following calls occur.

->arch/ia64/kernel/setup.c:setup_arch()
 ->parse_early_param()
  ->setup_early_serial8250_console()    N.B callback
   ->early_serial8250_setup()
    ->init_port()
     ->serial_out()
      ->outb()
       ->__outb()
        ->platform_outb()
         ->ia64_mv.outb()

However, ia64_mv may not be set until after machvec_init() is called
by setup_arch(), which occurs after the call to parse_early_param().

The reason for this ordering is that machvec_init() may be
influenced by the machvec command line argument, which
is also handled by early_param. A chicken an egg problem.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 
 arch/ia64/kernel/machvec.c |   27 ++++++++++++++++++---------
 arch/ia64/kernel/setup.c   |   11 ++++++++---
 include/asm-ia64/machvec.h |    1 +
 3 files changed, 27 insertions(+), 12 deletions(-)
Index: linux-2.6/arch/ia64/kernel/machvec.c
=================================--- linux-2.6.orig/arch/ia64/kernel/machvec.c	2007-07-25 14:52:55.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/machvec.c	2007-07-25 15:47:28.000000000 +0900
@@ -13,14 +13,6 @@
 struct ia64_machine_vector ia64_mv;
 EXPORT_SYMBOL(ia64_mv);
 
-static __initdata const char *mvec_name;
-static __init int setup_mvec(char *s)
-{
-	mvec_name = s;
-	return 0;
-}
-early_param("machvec", setup_mvec);
-
 static struct ia64_machine_vector * __init
 lookup_machvec (const char *name)
 {
@@ -41,7 +33,7 @@ machvec_init (const char *name)
 	struct ia64_machine_vector *mv;
 
 	if (!name)
-		name = mvec_name ? mvec_name : acpi_get_sysname();
+		name = acpi_get_sysname();
 	mv = lookup_machvec(name);
 	if (!mv)
 		panic("generic kernel failed to find machine vector for"
@@ -51,6 +43,23 @@ machvec_init (const char *name)
 	printk(KERN_INFO "booting generic kernel on platform %s\n", name);
 }
 
+void __init
+machvec_init_from_cmdline(const char *cmdline)
+{
+	char str[64];
+	const char *start;
+	char *end;
+
+	if (! (start = strstr(cmdline, "machvec=")) )
+		return machvec_init(NULL);
+
+	strlcpy(str, start + strlen("machvec="), sizeof(str));
+	if ( (end = strchr(str, ' ')) )
+		*end = '\0';
+
+	return machvec_init(str);
+}
+
 #endif /* CONFIG_IA64_GENERIC */
 
 void
Index: linux-2.6/arch/ia64/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/kernel/setup.c	2007-07-25 14:52:55.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/setup.c	2007-07-25 15:57:02.000000000 +0900
@@ -491,12 +491,17 @@ setup_arch (char **cmdline_p)
 	efi_init();
 	io_port_init();
 
-	parse_early_param();
-
 #ifdef CONFIG_IA64_GENERIC
-	machvec_init(NULL);
+	/* machvec needs to be parsed from the command line
+	 * before parse_early_param() is called to ensure
+	 * that ia64_mv is initialised before any command line
+	 * settings may cause console setup to occur
+	 */
+	machvec_init_from_cmdline(*cmdline_p);
 #endif
 
+	parse_early_param();
+
 	if (early_console_setup(*cmdline_p) = 0)
 		mark_bsp_online();
 
Index: linux-2.6/include/asm-ia64/machvec.h
=================================--- linux-2.6.orig/include/asm-ia64/machvec.h	2007-07-25 14:52:55.000000000 +0900
+++ linux-2.6/include/asm-ia64/machvec.h	2007-07-25 15:21:37.000000000 +0900
@@ -275,6 +275,7 @@ struct ia64_machine_vector {
 
 extern struct ia64_machine_vector ia64_mv;
 extern void machvec_init (const char *name);
+extern void machvec_init_from_cmdline(const char *cmdline);
 
 # else
 #  error Unknown configuration.  Update asm-ia64/machvec.h.

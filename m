From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 13 Mar 2006 06:33:27 +0000
Subject: RE: [RFC] IA64: Use early_parm to handle mvec_name and nomca
Message-Id: <200603130633.k2D6XRg17557@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060310082445.GA18715@verge.net.au>
In-Reply-To: <20060310082445.GA18715@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Horms wrote on Sunday, March 12, 2006 8:08 PM
> IA64: Use early_parm to handle mvec_name and nomca
> 
> I'm not sure of the worthiness of this idea, so please consider it an RFC. 
> Its key merits are:
> 
> * Reuse existing infrastructure
> * Greatly tightens up the parsing of nomca
> * Greatly simplifies the parsing of machvec

It is kind of odd though that parse_early_param() is called twice,
once from init/main.c:start_kernel and once from arch/ia64/kernel/
setup.c:setup_arch.  Though you are not the one introduces that
Oddity.

The other thing is that the code you changed are going to be thrown
away after initialization, so I take your motivation of the patch
is in some form of uncluttered the source code?

If I were you, I would put machvec code into machvec.c, like this:


 machvec.c |   17 ++++++++++++++---
 setup.c   |   30 +++++-------------------------
 2 files changed, 19 insertions(+), 28 deletions(-)

--- ./arch/ia64/kernel/machvec.c.orig	2006-03-12 22:52:30.208644445 -0800
+++ ./arch/ia64/kernel/machvec.c	2006-03-12 23:07:09.688125859 -0800
@@ -14,6 +14,14 @@
 struct ia64_machine_vector ia64_mv;
 EXPORT_SYMBOL(ia64_mv);
 
+static __initdata const char *mvec_name;
+static __init int setup_mvec(char *s)
+{
+	mvec_name = s;
+	return 0;
+}
+early_param("machvec", setup_mvec);
+
 static struct ia64_machine_vector * __init
 lookup_machvec (const char *name)
 {
@@ -33,10 +41,13 @@ machvec_init (const char *name)
 {
 	struct ia64_machine_vector *mv;
 
+	if (!name)
+		name = mvec_name ? mvec_name : acpi_get_sysname();
 	mv = lookup_machvec(name);
-	if (!mv) {
-		panic("generic kernel failed to find machine vector for platform %s!", name);
-	}
+	if (!mv)
+		panic("generic kernel failed to find machine vector for"
+		      " platform %s!", name);
+
 	ia64_mv = *mv;
 	printk(KERN_INFO "booting generic kernel on platform %s\n", name);
 }
--- ./arch/ia64/kernel/setup.c.orig	2006-03-12 22:53:16.178370444 -0800
+++ ./arch/ia64/kernel/setup.c	2006-03-12 23:01:43.595356416 -0800
@@ -402,35 +402,15 @@ setup_arch (char **cmdline_p)
 	efi_init();
 	io_port_init();
 
-#ifdef CONFIG_IA64_GENERIC
-	{
-		const char *mvec_name = strstr (*cmdline_p, "machvec=");
-		char str[64];
-
-		if (mvec_name) {
-			const char *end;
-			size_t len;
-
-			mvec_name += 8;
-			end = strchr (mvec_name, ' ');
-			if (end)
-				len = end - mvec_name;
-			else
-				len = strlen (mvec_name);
-			len = min(len, sizeof (str) - 1);
-			strncpy (str, mvec_name, len);
-			str[len] = '\0';
-			mvec_name = str;
-		} else
-			mvec_name = acpi_get_sysname();
-		machvec_init(mvec_name);
-	}
-#endif
-
 	if (early_console_setup(*cmdline_p) = 0)
 		mark_bsp_online();
 
 	parse_early_param();
+
+#ifdef CONFIG_IA64_GENERIC
+	machvec_init(NULL);
+#endif
+
 #ifdef CONFIG_ACPI
 	/* Initialize the ACPI boot-time table parser */
 	acpi_table_init();


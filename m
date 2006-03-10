From: Horms <horms@verge.net.au>
Date: Fri, 10 Mar 2006 08:24:46 +0000
Subject: [RFC] IA64: Use early_parm to handle mvec_name and nomca
Message-Id: <20060310082445.GA18715@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm not sure of the worthiness of this idea, so please consider it an RFC. 
Its key merits are:

* Reuse existing infrastructure
* Greatly tightens up the parsing of nomca
* Greatly simplifies the parsing of machvec

Signed-Off-By: Horms <horms@verge.net.au>

 setup.c |   47 ++++++++++++++++++++++++-----------------------
 1 file changed, 24 insertions(+), 23 deletions(-)

4ed9fbfd2b02aea51ee5848966465397eec5a1c6
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 3258e09..53a60fa 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -389,6 +389,24 @@ check_for_logical_procs (void)
 }
 #endif
 
+#ifdef CONFIG_IA64_GENERIC
+static const char *mvec_name = NULL;
+static __init int setup_mvec(char *s)
+{
+	mvec_name = s;
+	return 0;
+}
+early_param("machvec", setup_mvec);
+#endif
+
+static int nomca = 0;
+static __init int setup_nomca(char *s)
+{
+	nomca = 1;
+	return 0;
+}
+early_param("nomca", setup_nomca);
+
 void __init
 setup_arch (char **cmdline_p)
 {
@@ -402,35 +420,18 @@ setup_arch (char **cmdline_p)
 	efi_init();
 	io_port_init();
 
-#ifdef CONFIG_IA64_GENERIC
-	{
-		const char *mvec_name = strstr (*cmdline_p, "machvec=");
-		char str[64];
+	parse_early_param();
 
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
+#ifdef CONFIG_IA64_GENERIC
+	if (!mvec_name)
+		machvec_init(acpi_get_sysname());
+	else
 		machvec_init(mvec_name);
-	}
 #endif
 
 	if (early_console_setup(*cmdline_p) = 0)
 		mark_bsp_online();
 
-	parse_early_param();
 #ifdef CONFIG_ACPI
 	/* Initialize the ACPI boot-time table parser */
 	acpi_table_init();
@@ -493,7 +494,7 @@ setup_arch (char **cmdline_p)
 #endif
 
 	/* enable IA-64 Machine Check Abort Handling unless disabled */
-	if (!strstr(saved_command_line, "nomca"))
+	if (!nomca)
 		ia64_mca_init();
 
 	platform_setup(cmdline_p);

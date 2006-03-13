From: Horms <horms@verge.net.au>
Date: Mon, 13 Mar 2006 04:08:26 +0000
Subject: Re: [RFC] IA64: Use early_parm to handle mvec_name and nomca
Message-Id: <20060313040825.GA31703@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060310082445.GA18715@verge.net.au>
In-Reply-To: <20060310082445.GA18715@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Mar 11, 2006 at 09:51:41AM +0100, Jes Sorensen wrote:
> Horms wrote:
> >Below is a fressh diff that resolves those initialisation problems.
> 
> You're still zero initializingn them in the new diff ;-(

Sorry, sent the wrong thing :(

[snip]

On Sat, Mar 11, 2006 at 12:17:39PM -0800, Chen, Kenneth W wrote:
> Jes Sorensen wrote on Saturday, March 11, 2006 12:52 AM
> > > I was actually thinking that the main drawback of this appoach was the
> > > extra space devoted to these variables. Marking them as __init made the
> > > linker very unhappy. Given their current delaration, will they just
> > > stick around forever?
> > > 
> > 
> > Yous hould be able to mark them __init, otherwise they just end up
> > sticking around forever as you say. Grep around some other code in the
> > vicinity to see how it's declared if it causes problems.
> 
> You should use __initdata.

Thanks,

The patch below should address the BSS and __initdata deficiencies.
I also did a bit more testing, and it does indeed seem to work.

-- 
Horms

IA64: Use early_parm to handle mvec_name and nomca

I'm not sure of the worthiness of this idea, so please consider it an RFC. 
Its key merits are:

* Reuse existing infrastructure
* Greatly tightens up the parsing of nomca
* Greatly simplifies the parsing of machvec

Signed-Off-By: Horms <horms@verge.net.au>

 setup.c |   47 ++++++++++++++++++++++++-----------------------
 1 file changed, 24 insertions(+), 23 deletions(-)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 3258e09..afabe1b 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -389,6 +389,24 @@ check_for_logical_procs (void)
 }
 #endif
 
+#ifdef CONFIG_IA64_GENERIC
+static __initdata const char *mvec_name;
+static __init int setup_mvec(char *s)
+{
+	mvec_name = s;
+	return 0;
+}
+early_param("machvec", setup_mvec);
+#endif
+
+static __initdata int nomca;
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

From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 04 May 2004 16:34:18 +0000
Subject: Re: [ia64 R&D] CONFIG_IA64_MCA
Message-Id: <200405040934.18544.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_KY8lAHXY9rCVc13"
List-Id: <linux-ia64.vger.kernel.org>
References: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
In-Reply-To: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
To: linux-ia64@vger.kernel.org


--Boundary-00=_KY8lAHXY9rCVc13
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday, May 4, 2004 9:06 am, CURRY,JOHN W (HP-Cupertino,ex1) wrote:
> Yes, I think that could work. Tell me more. I have already communicated
> with Jesse, though.

It might look something like this (though now that I've looked at it, it seems 
we could use an early option parser for ia64).  I've tried to add a 'nomca' 
boot option that you can pass to the kernel to avoid registering the MCA 
handlers with the firmware.  This kernel builds and boots for me w/o the 
'nomca' option, but on sn2 it hangs at boot if I pass 'nomca'.

Jesse



--Boundary-00=_KY8lAHXY9rCVc13
Content-Type: text/plain;
  charset="iso-8859-1";
  name="no-mca-register.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="no-mca-register.patch"

===== arch/ia64/kernel/setup.c 1.70 vs edited =====
--- 1.70/arch/ia64/kernel/setup.c	Wed Mar 17 04:46:59 2004
+++ edited/arch/ia64/kernel/setup.c	Tue May  4 09:23:34 2004
@@ -283,6 +283,9 @@
 void __init
 setup_arch (char **cmdline_p)
 {
+	char *cp;
+	int nomca = 0;
+
 	unw_init();
 
 	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
@@ -359,9 +362,19 @@
 		conswitchp = &vga_con;
 # endif
 #endif
-
-	/* enable IA-64 Machine Check Abort Handling */
-	ia64_mca_init();
+	for (cp = saved_command_line; *cp; )
+		if (memcmp(cp, "nomca", 5) == 0)
+			nomca = 1;
+		else {
+			while (*cp != ' ' && *cp)
+				++cp;
+			while (*cp == ' ')
+				++cp;
+		}
+
+	/* enable IA-64 Machine Check Abort Handling unless disabled */
+	if (!nomca)
+		ia64_mca_init();
 
 	platform_setup(cmdline_p);
 	paging_init();

--Boundary-00=_KY8lAHXY9rCVc13--

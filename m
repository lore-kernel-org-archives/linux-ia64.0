From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 28 Oct 2004 02:36:56 +0000
Subject: Making NUMA/ACPI Kconfig options more explicit
Message-Id: <20041028023656.GA13721@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="DKU6Jbt7q3WqK7+M"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--DKU6Jbt7q3WqK7+M
Content-Type: multipart/mixed; boundary="Nq2Wo0NMKNjxTN9z"
Content-Disposition: inline


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

This trivial suggested patch does the following :

 - IA64 won't work without ACPI, so turn it on
 - NUMA won't work without ACPI_NUMA and SMP so turn them on

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="Kconfig-acpi-numa.diff"

===== arch/ia64/Kconfig 1.82 vs edited =====
--- 1.82/arch/ia64/Kconfig	2004-10-01 04:49:13 +10:00
+++ edited/arch/ia64/Kconfig	2004-10-28 12:30:07 +10:00
@@ -12,6 +12,7 @@
 config IA64
 	bool
 	default y
+	select ACPI
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
 	  the 32-bit X86 line.  The IA-64 Linux project has a home
@@ -49,7 +50,6 @@
 config IA64_GENERIC
 	bool "generic"
 	select NUMA
-	select ACPI_NUMA
 	select VIRTUAL_MEM_MAP
 	select DISCONTIGMEM
 	help
@@ -161,6 +161,8 @@
 # align cache-sensitive data to 64 bytes
 config NUMA
 	bool "NUMA support"
+	select ACPI_NUMA
+	select SMP
 	depends on !IA64_HP_SIM
 	default y if IA64_SGI_SN2
 	help

--Nq2Wo0NMKNjxTN9z--

--DKU6Jbt7q3WqK7+M
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBgFtIWDlSU/gp6ecRAhIwAJ9vvgNBpN0B7bmKlPKnGX0FAD9+WACeNuTs
YP8xJkATn4UmZ6HO59KAMB0=
=lGPg
-----END PGP SIGNATURE-----

--DKU6Jbt7q3WqK7+M--

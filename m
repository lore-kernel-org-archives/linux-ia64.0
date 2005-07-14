From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 14 Jul 2005 04:09:10 +0000
Subject: Fix undefined reference to can_cpei_retarget for simulator build
Message-Id: <20050714040909.GB15249@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0vzXIDBeUiKkjNJl"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--0vzXIDBeUiKkjNJl
Content-Type: multipart/mixed; boundary="cvVnyQ+4j833TQvp"
Content-Disposition: inline


--cvVnyQ+4j833TQvp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

The change @ http://tinyurl.com/dsxf4 broke the simulator build
(http://www.gelato.unsw.edu.au/kerncomp).

The simulator build doesn't turn on ACPI, so doesn't have a definition
of can_cpei_retarget.  Suggested patch attached.

Thanks,

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

--cvVnyQ+4j833TQvp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="topology.c-acpi.diff"

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -36,12 +36,14 @@ int arch_register_cpu(int num)
 	parent = &sysfs_nodes[cpu_to_node(num)];
 #endif /* CONFIG_NUMA */
 
+#ifdef CONFIG_ACPI_BOOT
 	/*
 	 * If CPEI cannot be re-targetted, and this is
 	 * CPEI target, then dont create the control file
 	 */
 	if (!can_cpei_retarget() && is_cpu_cpei_target(num))
 		sysfs_cpus[num].cpu.no_control = 1;
+#endif
 
 	return register_cpu(&sysfs_cpus[num].cpu, num, parent);
 }

--cvVnyQ+4j833TQvp--

--0vzXIDBeUiKkjNJl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFC1eVlWDlSU/gp6ecRAqPIAKDCqKAU//SAqp8AtBCANyI8wM+QIwCdH1/3
Iva2hiDoa80DJVciIRiK5QI=
=rh01
-----END PGP SIGNATURE-----

--0vzXIDBeUiKkjNJl--

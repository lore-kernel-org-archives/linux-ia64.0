From: Andreas Schwab <schwab@suse.de>
Date: Wed, 16 May 2001 14:15:37 +0000
Subject: [Linux-ia64] maxcpus=1 does not work
Message-Id: <marc-linux-ia64-105590693005591@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Passing maxcpus=3D1 as boot parameter does not have the expected effect: all
cpus are still enabled.

--- arch/ia64/kernel/smp.c	2001/05/16 14:01:20	1.1
+++ arch/ia64/kernel/smp.c	2001/05/16 14:02:10
@@ -637,7 +637,7 @@
 	if (max_cpus !=3D -1)
 		printk("Limiting CPUs to %d\n", max_cpus);
=20
-	if (smp_boot_data.cpu_count > 1) {
+	if (smp_boot_data.cpu_count > 1 && cpu_count !=3D max_cpus) {
 		printk(KERN_INFO "SMP: starting up secondaries.\n");
=20
 		for (i =3D 0; i < smp_boot_data.cpu_count; i++) {

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5


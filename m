From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Thu, 19 Dec 2002 07:53:06 +0000
Subject: [Linux-ia64] Can't boot in SMP with kernel 2.5.50 ia64
Message-Id: <marc-linux-ia64-105590709805616@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

Booting 2.5.50 with David's patch, it seems we can't boot in SMP on an=20
ia64 machine. We get the message: SMP mode deactivated.
Problem is due to smp_prepare_cpus() declaring max_cpus as "unsigned
int" and testing against the -1 value.
Problem was not seen in 2.5.45 because max_cpus was initialized to
UINT_MAX.

Boot in SMP is OK with the following patch:

diff --exclude-from /home/xb/proc/diff.exclude -Nur 2.5.50.ref/arch/ia64/ke=
rnel/smpboot.c 2.5.50/arch/ia64/kernel/smpboot.c
--- 2.5.50.ref/arch/ia64/kernel/smpboot.c	Wed Dec 18 11:15:48 2002
+++ 2.5.50/arch/ia64/kernel/smpboot.c	Wed Dec 18 15:11:52 2002
@@ -472,7 +472,7 @@
  * Cycle through the APs sending Wakeup IPIs to boot each.
  */
 void __init
-smp_prepare_cpus (unsigned int max_cpus)
+smp_prepare_cpus (int max_cpus)
 {
 	int boot_cpu_id =3D hard_smp_processor_id();
=20
diff --exclude-from /home/xb/proc/diff.exclude -Nur 2.5.50.ref/include/linu=
x/smp.h 2.5.50/include/linux/smp.h
--- 2.5.50.ref/include/linux/smp.h	Wed Dec 18 11:15:48 2002
+++ 2.5.50/include/linux/smp.h	Wed Dec 18 15:28:47 2002
@@ -34,7 +34,7 @@
 /*
  * Prepare machine for booting other CPUs.
  */
-extern void smp_prepare_cpus(unsigned int max_cpus);
+extern void smp_prepare_cpus(int max_cpus);
=20
 /*
  * Bring a CPU up

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


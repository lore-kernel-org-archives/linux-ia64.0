From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Date: Sat, 03 May 2003 13:00:00 +0000
Subject: [Linux-ia64] PATCH 2.5.68] mod_timer fixes for ia64/sn/kernel/mca.c
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-LkUUa/avS6wP6hhWIUla"
Message-Id: <marc-linux-ia64-105590723705632@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--=-LkUUa/avS6wP6hhWIUla
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi,

Few more {del,add}_timer to mod_timer conversions.

vinay

PS: I am not on the mailing list.

--=-LkUUa/avS6wP6hhWIUla
Content-Disposition: attachment; filename=mca.c.diff
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; name=mca.c.diff; charset=UTF-8

--- linux-2.5.68/arch/ia64/sn/kernel/mca.c	2003-03-25 10:07:20.000000000 +0=
530
+++ linux-2.5.68-nvk/arch/ia64/sn/kernel/mca.c	2003-05-03 16:50:57.00000000=
0 +0530
@@ -246,9 +246,7 @@
 void
 sn_cpei_timer_handler(unsigned long dummy) {
         sn_cpei_handler(-1, NULL, NULL);
-        del_timer(&sn_cpei_timer);
-        sn_cpei_timer.expires =3D jiffies + CPEI_INTERVAL;
-        add_timer(&sn_cpei_timer);
+        mod_timer(&sn_cpei_timer, jiffies + CPEI_INTERVAL);
 }
=20
 void
@@ -267,9 +265,7 @@
         unsigned long *pi_ce_error_inject_reg =3D 0xc00000092fffff00;
=20
         *pi_ce_error_inject_reg =3D 0x0000000000000100;
-        del_timer(&sn_ce_timer);
-        sn_ce_timer.expires =3D jiffies + CPEI_INTERVAL;
-        add_timer(&sn_ce_timer);
+        mod_timer(&sn_ce_timer, jiifies + CPEI_INTERVAL);
 }
=20
 sn_init_ce_timer() {

--=-LkUUa/avS6wP6hhWIUla--



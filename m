From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 27 Sep 2001 04:57:34 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805264@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Some of us are still using gcc 2.96 which does not support --param
max-inline-insns.

Index: 10.15/arch/ia64/Makefile
--- 10.15/arch/ia64/Makefile Thu, 27 Sep 2001 14:15:19 +1000 kaos (linux-2.=
4/s/c/42_Makefile 1.1.3.1.3.3 644)
+++ 10.15(w)/arch/ia64/Makefile Thu, 27 Sep 2001 14:42:23 +1000 kaos (linux=
-2.4/s/c/42_Makefile 1.1.3.1.2.4 644)
@@ -17,9 +17,10 @@ LINKFLAGS =3D -static -T arch/$(ARCH)/vmli
 AFLAGS_KERNEL :=3D -mconstant-gp
 EXTRA	=20
-CFLAGS :=3D $(CFLAGS) -pipe $(EXTRA) -ffixed-r13 -mfixed-range=F10-f15,f32=
-f127 \
-	  -falign-functions2 --param max-inline-insns@0
-# -ffunction-sections
+CFLAGS :=3D $(CFLAGS) -pipe $(EXTRA) -ffixed-r13 -mfixed-range=F10-f15,f32=
-f127 -falign-functions2
+
+CFLAGS +=3D $(shell if $(CC) --param max-inline-insns@0 -S -o /dev/null -x=
c /dev/null >/dev/null 2>&1; then echo "--param max-inline-insns@0"; fi)
+
 CFLAGS_KERNEL :=3D -mconstant-gp
=20
 GCC_VERSION=3D$(shell $(CROSS_COMPILE)$(HOSTCC) -v 2>&1 | fgrep 'gcc versi=
on' | cut -f3 -d' ' | cut -f1 -d'.')



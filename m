From: Andreas Schwab <schwab@suse.de>
Date: Sun, 01 Apr 2001 18:24:22 +0000
Subject: Re: [Linux-ia64] kernel update (third patch relative to 2.4.2)
Message-Id: <marc-linux-ia64-105590693005373@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005356@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005356@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|> The latest IA-64 patch is now available at:
|>=20
|>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/
|>=20
|> in file linux-2.4.2-ia64-010326.diff*
|>=20
|> The only two changes are:
|>=20
|> 	o fix do_csum_partial_copy_from_user() to work properly
|> 	o fix ia64_ksyms.c so it compiles for UP as well

Actually, for UP we need to export __flush_tlb_all for the agpgart module.

--- ia64_ksyms.c	2001/03/28 11:36:05	1.1
+++ ia64_ksyms.c	2001/04/01 17:59:28
@@ -52,9 +52,11 @@
 EXPORT_SYMBOL_NOVERS(__down_write_failed);
 EXPORT_SYMBOL_NOVERS(__rwsem_wake);
=20
-#ifdef CONFIG_SMP
 #include <asm/pgalloc.h>
+#ifdef CONFIG_SMP
 EXPORT_SYMBOL(smp_flush_tlb_all);
+#else
+EXPORT_SYMBOL(__flush_tlb_all);
 #endif
=20
 #include <asm/page.h>

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5


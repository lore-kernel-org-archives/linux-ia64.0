From: Xavier Bru <Xavier.Bru@bull.net>
Date: Mon, 06 Oct 2003 16:54:09 +0000
Subject: Re: [PATCH] more discontig stuff
Message-Id: <marc-linux-ia64-106545921815061@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106488076517737@msgid-missing>
In-Reply-To: <marc-linux-ia64-106488076517737@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Hi Jesse

Thanks for your answer. This new one boots OK with CONFIG_NUMA (zones
have now free_pages non 0 at first __alloc_pages).

I applied it on 2.6.0-test5 + your patch dated Sept 22.

I just added a fix to prevent some redeclarations in  meminit.h with
gcc 3.2 :

--- linux-2.6.0-test5/include/asm-ia64/meminit.h 2003-10-06 10:51:45.000000=
000 +0200
+++ 0t5/include/asm-ia64/meminit.h	2003-10-01 18:56:09.000000000 +0200
@@ -14,6 +14,8 @@
  *
  * More could be added if necessary
  */
+#ifndef _ASM_IA64_MEMINIT_H
+#define _ASM_IA64_MEMINIT_H
 #define IA64_MAX_RSVD_REGIONS 5
=20
 struct rsvd_region {
@@ -58,3 +60,4 @@
=20
 #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss
 				   handler is updated... */
+#endif /* _ASM_IA64_MEMINIT_H */

Thanks again.

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


Jesse Barnes writes:
 > On Fri, Oct 03, 2003 at 06:50:37PM +0200, Xavier Bru wrote:
 > > ... not too much on our DIG64 platform ;-(
 >=20
 > Thanks for looking at it.
 >=20
 > > But the previous one dated sept 23 looked OK :-)
 >=20
 > I fixed a few bugs in the patch since I posted it.  Can you try this
 > one?  I'll have to try your kdb patch too...
 >=20
 > A really dumb bug that I introduced while trying to go above 64p was the
 > is_headless_node() thing (but I don't think that would affect your
 > platform).  any_online_cpu(cpumask_t) is undefined if there are no bits
 > set.
 >=20
 > Thanks,
 > Jesse
 >=20

From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 27 Apr 2004 11:57:19 +0000
Subject: RE: [PATCH] bug w/ shared interrupts
Message-Id: <MDEEKOKJPMPMKGHIFAMAOEPIDNAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_NextPart_000_000A_01C42C9A.3A7D4350"
List-Id: <linux-ia64.vger.kernel.org>
References: <1082989740.15656.20.camel@localhost>
In-Reply-To: <1082989740.15656.20.camel@localhost>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_000A_01C42C9A.3A7D4350
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit

Hi,

I don't know whether you are referring to my patch. But if so,
please try a following patch. The patch for sharing vector I sent
before contains a bug and I think this might cause a similar problem.

Thanks,
Kenji Kaneshige


This is a patch to fix the following bug:

Register_intr() changes pin->low32 even when it overrides the
interrupt info. This destroys the value of pin->low32 which is already
set by set_rte() or other staffs.

This patch is against linux-2.6.6-rc2 with share_vector.patch applied.


---

 linux-2.6.6-rc2-kanesige/arch/ia64/kernel/iosapic.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN arch/ia64/kernel/iosapic.c~share_vector_bugfix
arch/ia64/kernel/iosapic.c
--- linux-2.6.6-rc2/arch/ia64/kernel/iosapic.c~share_vector_bugfix
2004-04-27 18:12:56.000000000 +0900
+++ linux-2.6.6-rc2-kanesige/arch/ia64/kernel/iosapic.c	2004-04-27
18:12:56.000000000 +0900
@@ -605,7 +605,6 @@ register_intr (unsigned int gsi, int vec
 		pin->polarity = polarity;
 		pin->addr     = iosapic_address;
 		pin->gsi_base = gsi_base;
-		pin->low32    = IOSAPIC_MASK;
 		iosapic_intr_info[vector].dmode   = delivery;
 		iosapic_intr_info[vector].trigger = trigger;
 		iosapic_intr_info[vector].type    = type;

_

------=_NextPart_000_000A_01C42C9A.3A7D4350
Content-Type: application/octet-stream;
	name="share_vector_bugfix.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="share_vector_bugfix.patch"

=0A=
This is a patch to fix the following bug:=0A=
=0A=
Register_intr() changes pin->low32 even when it overrides the=0A=
interrupt info. This destroys the value of pin->low32 which is already=0A=
set by set_rte() or other staffs.=0A=
=0A=
This patch is against linux-2.6.6-rc2 with share_vector.patch applied.=0A=
=0A=
=0A=
---=0A=
=0A=
 linux-2.6.6-rc2-kanesige/arch/ia64/kernel/iosapic.c |    1 -=0A=
 1 files changed, 1 deletion(-)=0A=
=0A=
diff -puN arch/ia64/kernel/iosapic.c~share_vector_bugfix =
arch/ia64/kernel/iosapic.c=0A=
--- linux-2.6.6-rc2/arch/ia64/kernel/iosapic.c~share_vector_bugfix	=
2004-04-27 18:12:56.000000000 +0900=0A=
+++ linux-2.6.6-rc2-kanesige/arch/ia64/kernel/iosapic.c	2004-04-27 =
18:12:56.000000000 +0900=0A=
@@ -605,7 +605,6 @@ register_intr (unsigned int gsi, int vec=0A=
 		pin->polarity =3D polarity;=0A=
 		pin->addr     =3D iosapic_address;=0A=
 		pin->gsi_base =3D gsi_base;=0A=
-		pin->low32    =3D IOSAPIC_MASK;=0A=
 		iosapic_intr_info[vector].dmode   =3D delivery;=0A=
 		iosapic_intr_info[vector].trigger =3D trigger;=0A=
 		iosapic_intr_info[vector].type    =3D type;=0A=
=0A=
_=0A=

------=_NextPart_000_000A_01C42C9A.3A7D4350--


From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 19 May 2004 03:10:31 +0000
Subject: Re: Disable CONFIG_SMP for IA64_HP_SIM
Message-Id: <20040519031031.GB27655@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="wLAMOaPNJ0fu1fTG"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040519012326.GA27655@cse.unsw.EDU.AU>
In-Reply-To: <20040519012326.GA27655@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--wLAMOaPNJ0fu1fTG
Content-Type: multipart/mixed; boundary="xo44VMWPx7vlQ2+2"
Content-Disposition: inline


--xo44VMWPx7vlQ2+2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 19, 2004 at 02:59:13AM +0100, Matthew Wilcox wrote:
> On Tue, May 18, 2004 at 06:35:12PM -0700, David Mosberger wrote:
> > CONFIG_SMP probably shouldn't depend on CONFIG_IOSAPIC.
>=20
> I agree -- I think the SGI machines don't have an IOSAPIC.

I don't think it would effect the SGI machines as they have their own
arch/sn/kernel/irq.c?

My suggestion is attached.

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

--xo44VMWPx7vlQ2+2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="irqcpumask.patch"
Content-Transfer-Encoding: quoted-printable

=3D=3D=3D=3D=3D arch/ia64/kernel/iosapic.c 1.42 vs edited =3D=3D=3D=3D=3D
--- 1.42/arch/ia64/kernel/iosapic.c	Sat May 15 12:00:12 2004
+++ edited/arch/ia64/kernel/iosapic.c	Wed May 19 12:58:40 2004
@@ -100,7 +100,7 @@
 #endif
=20
 static spinlock_t iosapic_lock =3D SPIN_LOCK_UNLOCKED;
-cpumask_t	__cacheline_aligned pending_irq_cpumask[NR_IRQS];
+extern cpumask_t __cacheline_aligned pending_irq_cpumask[NR_IRQS];
=20
 /* These tables map IA-64 vectors to the IOSAPIC pin that generates this v=
ector. */
=20
=3D=3D=3D=3D=3D arch/ia64/kernel/irq.c 1.39 vs edited =3D=3D=3D=3D=3D
--- 1.39/arch/ia64/kernel/irq.c	Sat May 15 12:00:12 2004
+++ edited/arch/ia64/kernel/irq.c	Wed May 19 13:00:18 2004
@@ -56,8 +56,6 @@
 #include <asm/delay.h>
 #include <asm/irq.h>
=20
-extern cpumask_t    __cacheline_aligned pending_irq_cpumask[NR_IRQS];
-
 /*
  * Linux has a controller-independent x86 interrupt architecture.
  * every controller has a 'controller-template', that is used
@@ -84,6 +82,11 @@
 		.lock =3D SPIN_LOCK_UNLOCKED
 	}
 };
+
+/*=20
+ * This is updated when the user sets irq affinity via /proc
+ */=20
+cpumask_t    __cacheline_aligned pending_irq_cpumask[NR_IRQS];
=20
 #ifdef CONFIG_IA64_GENERIC
 irq_desc_t * __ia64_irq_desc (unsigned int irq)

--xo44VMWPx7vlQ2+2--

--wLAMOaPNJ0fu1fTG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAqtAnWDlSU/gp6ecRAgD7AKCENFD39F7mXcoppHm7jks23QGB/wCg3vAj
eMx/vuSzyN7NCCHNv29yRCA=
=ouMO
-----END PGP SIGNATURE-----

--wLAMOaPNJ0fu1fTG--

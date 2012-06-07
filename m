From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 07 Jun 2012 03:51:52 +0000
Subject: [PATCH] IA64: Export <asm/cmpxchg.h> to userland
Message-Id: <1339041112.21665.77.camel@deadeye.wl.decadent.org.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-doPXabYEVz7M66X1NSvo"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-doPXabYEVz7M66X1NSvo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Parts of <asm/intrinsics.h> were moved to <asm/cmpxchg.h>, and the
former now includes the latter.  The former is exported to userland
so the latter must be too.

Cc: stable@vger.kernel.org # v3.4
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Both these header files still provoke a lot of warnings from
headers_check, but this at least fixes the (new) fatal error.

Ben.

 arch/ia64/include/asm/Kbuild |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 241d1c5..c929a53 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -6,6 +6,7 @@ header-y +=3D gcc_intrin.h
 header-y +=3D ia64regs.h
 header-y +=3D intel_intrin.h
 header-y +=3D intrinsics.h
+header-y +=3D cmpxchg.h
 header-y +=3D perfmon.h
 header-y +=3D perfmon_default_smpl.h
 header-y +=3D ptrace_offsets.h
--=20
1.7.10



--=-doPXabYEVz7M66X1NSvo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT9AlWOe/yOyVhhEJAQqNsA//dHBWw6pDegrzCrsQAwzmDekQUG0hNKlP
AaJwE6Ks8qSASWu58WwglcqY4rruiNM6gCxQhBjdIbKveOcZkDQ37XMc2vNkF1Km
jBL5PYHIso7XI8PZFwSTm5eX8iv0HEpfnY8UmbVqU8Jpc4pPBKIpgukjANbCIGFo
6MWwD8kffZiZo5sbkKnHO2elvRJwTGQKf271mM65UJwNZl08olac4vVzxhVJMmoK
ScZNUF6LvTjcHGyr2gFN1DrYM5pQCyalVfYKqWLzKHaPetYiIkf2RHFIV5wTkxPe
4V7gTDI0cKBPclIRAqPY2Dvj/gkga7NBebHX7RKAFA8bGhOR1LxcKMyKgCSbyL8Q
NgQCVR8BUIQDym2+c6dvS4GGerMDjA1+wbzjyC4/tg3B/Gu7X3yqgciug62POZbT
RcehfkXaDpNEPeFxYr2bkQU7xYLypkTSnXeYqY9Kwmnk617SdoYFpE6U45bwMT7G
3PpZcpU/5m9QZs8+OABhwbYWrWsqunJNqRXDqSjVo2YpxJkkQDu5Ace94gMsrYnO
Q0IWbvtzO+Ki0BgtKBWHWcg6wrse9UsKxwIgFiPGAdASs0k1y4X02uVl28ibEX0J
+4JbB6xWdziAoP8CBOITX90wLtYheQa03rViNpQwDfX0M4/tAuhgvKln5TK4MqQz
6EPd3g83hq8=
=h+M/
-----END PGP SIGNATURE-----

--=-doPXabYEVz7M66X1NSvo--

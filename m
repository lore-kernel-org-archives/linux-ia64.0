From: Andreas Schwab <schwab@suse.de>
Date: Wed, 22 Aug 2001 10:00:44 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.9)
Message-Id: <marc-linux-ia64-105590698805095@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|> The latest IA-64 patch is available at:
|>=20
|>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/
|>=20
|> in file linux-2.4.9-ia64-010820.diff*.
|>=20
|> The big news in this patch is a major cleanup of the DRM source
|> tree(s) by Chris Ahna.  Much of the ia64 specific code has now been
|> restructured so it fits much better into the existing framework.  This
|> should make it a lot easier in getting the changes accepted by the DRM
|> maintainers.  Other changes:

The new DRM code (CONFIG_DRM_NEW) does not compile:

In file included from gamma_drv.c:92:
drm_memory.h: In function `gamma_ioremap':
drm_memory.h:319: structure has no member named `agp'
drm_memory.h:338: structure has no member named `agp'

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5


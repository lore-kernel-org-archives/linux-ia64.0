From: Sven Eckelmann <sven@narfation.org>
Date: Fri, 17 Jun 2011 17:32:57 +0000
Subject: Re: Re: [PATCHv3-resend] atomic: add *_dec_not_zero
Message-Id: <2834959.yriPZz3AFK@sven-desktop.home.narfation.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart5541730.OXMfvPS79y"
List-Id: <linux-ia64.vger.kernel.org>
References: <1306653200-19176-1-git-send-email-sven@narfation.org> <1308307124-15659-1-git-send-email-sven@narfation.org> <201106171713.12983.arnd@arndb.de>
In-Reply-To: <201106171713.12983.arnd@arndb.de>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arch@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org


--nextPart5541730.OXMfvPS79y
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="iso-8859-15"

On Friday 17 June 2011 17:13:12 Arnd Bergmann wrote:
> On Friday 17 June 2011, Sven Eckelmann wrote:
> > Introduce an *_dec_not_zero operation.  Make this a special case of
> > *_add_unless because batman-adv uses atomic_dec_not_zero in different
> > places like re-broadcast queue or aggregation queue management. There
> > are other non-final patches which may also want to use this macro.
> > 
> > Reported-by: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Sven Eckelmann <sven@narfation.org>
> > Acked-by: Mike Frysinger <vapier@gentoo.org>
> > Acked-by: James Bottomley <James.Bottomley@HansenPartnership.com>
> > Acked-by: David S. Miller <davem@davemloft.net>
> > Acked-by: Ingo Molnar <mingo@elte.hu>
> > Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>
> > Acked-by: Ralf Baechle <ralf@linux-mips.org>
> > Acked-by: David Howells <dhowells@redhat.com>
> > Acked-by: Chris Metcalf <cmetcalf@tilera.com>
> > Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
> > Acked-by: Will Deacon <will.deacon@arm.com>
> > Acked-by: Matt Turner <mattst88@gmail.com>
> > Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > Acked-by: Paul Mundt <lethal@linux-sh.org>
> > Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> > Acked-by: Hirokazu Takata <takata@linux-m32r.org>
> > Cc: Tony Luck <tony.luck@intel.com>
> > Cc: Fenghua Yu <fenghua.yu@intel.com>
> > Cc: linux-ia64@vger.kernel.org
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: linux-arch@vger.kernel.org
> > ---
> > Nothing changed - only added the Acked-by from Hirokazu Takata. That
> > means that I am still waiting for ia64 and Arnd Bergmann (maybe he wants
> > to merge it in his tree?).
> 
> Hmm, I didn't look at the first versions unfortunately. Remind me why we
> don't just open-code the atomic_add_unless in batman-adv.

Because some developers behind batman-adv and fault_inject thought that it is 
easier readable and David S. Miller said that it is a good idea to have 
something like it in atomic*.h

Other places were it can be used:
 * drivers/media/video/omap3isp/ispstat.c
 * drivers/s390/net/qeth_core_main.c
 * fs/ext4/ext4.h
 * fs/xfs/linux-2.6/xfs_buf.c
 * mm/memcontrol.c
 * net/core/drop_monitor.c
 * net/phonet/pep.c

> Since people apparently think that this patch is a good idea, I'll merge it
> in the asm-generic tree once I understand why this is done.

Don't feel pushed --- you can just say that you absolutely doesn't want it. I 
only tried to keep David happy, but don't want to start a fight over it.

thanks,
	Sven
--nextPart5541730.OXMfvPS79y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJN+4/JAAoJEF2HCgfBJntG+nUQAMoockMYpvuZf2ywjI9K9aYT
L1BrfR+yqiLpvymAcylh2StRsTKINb8+44oGM6gSoBlC+cvWS7G+UqFmL06KJPzp
vYliU2TEiImbeO0OvcrBAAcUAEPxoBQYP7rPWZ0Vbgia6ew9Jtb2wQfzuamnM7V+
2N1fvQ7pjFHuaLQ3E93pj6bpEmIUjm7G2taJrdQyeixH40HrBVbiXTKX9F0eDK7G
hbgcS0OO4G3Y6WESGmGBufKc8OoND0Nxn57dqkxok4IGYera9Gv0DJg8Sn5uPtqE
P1LqsukuROtni8NMVBKANSTtZ7T/lZBkz+nQtX0Y8poegPZyQEeGTEa1goYbgdzo
ejIKwG4zxHKldduaIEVk+0918eXuYXx3eRcQruxTrzvb7l232hf8IrVq8WQxMup2
KD8IH6AmXnKrQfmqIl7fh4tIPsx0i1tGFaYIVEygG+u0hOzvvrs0IkkKYAakBdrc
/tOdP+8PABm3zoiUE2L9JtN6wN+Hp1pz/7YnIHdoV8wC22DoZOq/qlC10VdWJti/
/e9xDtLuBwbM6InpMeNeKjDoCTaBua5w9Qsi7Z5DGsmzfjTA7AzhkkqxxDtajmNo
itTEmPohS0mvvuX52jLWX3Jd7N2XTNvcuiMSzN8vNyJJQPfGOPh/FQbvv2FPnqH5
RBVkQao68axukldGQ7uJ
=H+kb
-----END PGP SIGNATURE-----

--nextPart5541730.OXMfvPS79y--


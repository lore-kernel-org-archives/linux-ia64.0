From: Andreas Schwab <schwab@suse.de>
Date: Thu, 24 Nov 2005 17:54:19 +0000
Subject: Understanding early mm initialisation
Message-Id: <jed5kqextg.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I'm trying to track down a bug that appears to be a miscompilation with
the latest gcc 4.1 head, but I haven't been able to figure out where to
look.  The problem is that the first call to set_page_zone that happens in
memmap_init_zone leads to a crash, as if vmem_map points to unmapped
memory.  Now I'm trying to understand where the memory for vmem_map is
actually mapped and how I can find out whether that mapping is indeed
valid.

Thanks, Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

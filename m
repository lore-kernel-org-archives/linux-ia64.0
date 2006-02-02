From: Andreas Schwab <schwab@suse.de>
Date: Thu, 02 Feb 2006 10:13:37 +0000
Subject: Re: [PATCH 1/12] generic *_bit()
Message-Id: <jemzhajcfi.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201193933.GA16471@esmail.cup.hp.com>
	<200602012141.k11LfCg32497@unix-os.sc.intel.com>
	<20060201220903.GE16471@esmail.cup.hp.com>
	<Pine.LNX.4.64.0602012246330.3680@hermes-2.csi.cam.ac.uk>
	<20060202000820.GI16471@esmail.cup.hp.com>
	<Pine.LNX.4.64.0602020849160.785@hermes-2.csi.cam.ac.uk>
In-Reply-To: <Pine.LNX.4.64.0602020849160.785@hermes-2.csi.cam.ac.uk> (Anton
	Altaparmakov's message of "Thu, 2 Feb 2006 08:52:11 +0000 (GMT)")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Anton Altaparmakov <aia21@cam.ac.uk>
Cc: Grant Grundler <iod00d@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Hellwig' <hch@infradead.org>, 'Akinobu Mita' <mita@miraclelinux.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Anton Altaparmakov <aia21@cam.ac.uk> writes:

> The name seems a bit silly as I imagine most fs drivers would be able to =

> use them and there already are ext2 and minix versions.  Probably ought=20
> be renamed to a more generic name like le_test_bit() or something...

Minix is even more complicated, since the on-disk format is different
between architectures (the m68k port of Minix did not handle that
correctly).

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

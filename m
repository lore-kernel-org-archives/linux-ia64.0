From: Andreas Schwab <schwab@suse.de>
Date: Fri, 12 Jan 2007 10:33:22 +0000
Subject: Re: [PATCH] Kdump documentation update for 2.6.20: ia64 portion
Message-Id: <je1wm0h6vh.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070112060724.GC17379@verge.net.au>
	<10EA09EFD8728347A513008B6B0DA77A086BAA@pdsmsx411.ccr.corp.intel.com>
	<20070112090043.GA27340@verge.net.au>
In-Reply-To: <20070112090043.GA27340@verge.net.au> (horms@verge.net.au's
	message of "Fri, 12 Jan 2007 18:00:44 +0900")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Horms <horms@verge.net.au>
Cc: "Zou, Nanhai" <nanhai.zou@intel.com>, Vivek Goyal <vgoyal@in.ibm.com>, Mohan Kumar M <mohan@in.ibm.com>, Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org, linux-ia64@vger.kernel.org

Horms <horms@verge.net.au> writes:

> +  If the start address is specified, not that the start address of the
                                        note
> +  kernel will be alligned to 64Mb, so any if the start address is not th=
en
                    aligned              XXX
> +  any space below the alignment point will be wasted.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

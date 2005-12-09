From: Andreas Schwab <schwab@suse.de>
Date: Fri, 09 Dec 2005 19:41:44 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <jeirtyawhz.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

> That looks like a plausible direction to investigate.  Does anyone know
> whether any other architectures have a similar problem that can be solved
> in this way?  Or is ia64 the only one with a "generic" kernel that has to
> work on such a diverse spread of machines?

PPC has CONFIG_PPC_MULTIPLATFORM, and use ppc_md much like ia64 uses
ia64_mv.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

From: Phil Carmody <ext-phil.2.carmody@nokia.com>
Date: Wed, 15 Sep 2010 22:22:16 +0000
Subject: Re: [PATCH 0/2] ia64: possible module unwind table optimisation
Message-Id: <20100915222216.GF27658@esdhcp04044.research.nokia.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1284115245-23876-1-git-send-email-ext-phil.2.carmody@nokia.com> <AANLkTi=RsA0tACWOg+8RTSuDHwa4LGOiyO-4TxpJ_rb5@mail.gmail.com> <20100915124831.GB27658@esdhcp04044.research.nokia.com> <AANLkTi=hPcXC1=Lrey1H_UHRJRJ-NdTsvmyxgP_n+dM8@mail.gmail.com>
In-Reply-To: <AANLkTi=hPcXC1=Lrey1H_UHRJRJ-NdTsvmyxgP_n+dM8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: ext Tony Luck <tony.luck@intel.com>
Cc: "fenghua.yu@intel.com" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 15/09/10 19:28 +0200, ext Tony Luck wrote:
> On Wed, Sep 15, 2010 at 5:48 AM, Phil Carmody
> <ext-phil.2.carmody@nokia.com> wrote:
> >> =A0 for (table =3D unw.tables; table; table =3D table->next)
> >>
> >> before we find the right table to look?
> >
> > Yes, that's the one. Sorry I wasn't more explicit.
>=20
> My usual workload (building new Linux kernels - what else :-) doesn't
> seem to generate
> any unwind requests.  I reached the loop just 58 times while booting,
> and only did 23
> steps past the first item [didn't track a histogram, so I don't know
> whether that was a
> single 23 step lookup, or 23 one-step ones].  Building the kernel
> (make -j32) didn't add
> to either count.
>=20
> Workload ideas?

Turn on kmemleak, or anything else which repeatedly runs up the stack just
for the fun of gathering backtraces. Kmemleak's what caused us to notice=20
the issue in our ARM-based environment.

Phil

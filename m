From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Thu, 21 Sep 2006 00:27:10 +0000
Subject: RE: [Patch] IA64 Kexec/Kdump patch for 2.6.18-rc6
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086ABC@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1158288948.2591.195.camel@linux-znh>
In-Reply-To: <1158288948.2591.195.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Luck, Tony
> Sent: 2006=C4=EA9=D4=C221=C8=D5 0:43
> To: Horms; Zou, Nanhai
> Cc: Linux-IA64; fastboot
> Subject: RE: [Patch] IA64 Kexec/Kdump patch for 2.6.18-rc6
>=20
> > Tony, Nan Hai, do you have any thoughts on merging this
> > series into ia64 test? Its really far to big to be managed
> > as a single unit. I would be much more comfortable if
> > we could track small incremental changes. Even the diff
> > between the current and previous version (as below) is quite large.
>=20
> I'm open to suggestions.  My current inclination is to abandon the
> existing kexec/kdump patches that are currently in my test tree[1] and
> replace them with the latest set of patches.  So a re-diff of all that
> is considered good against 2.6.18 would be ideal for that.
>=20
> Breaking the patch into some smaller pieces would also be good,
> but I don't think this needs to be taken to extremes (just define
> a few basic areas and split the patch ... I don't thing it is
> worth spending days/weeks to split this into a sequence  of 37 individual=
ly
> crafted patches, with the kernel being fully functional at every
> one of the 36 intermediate points).
>=20
> -Tony
>=20
> [1] My test tree is not a guaranteed monotonic increasing sequence of
> changesets.  I've already blown it away once before to clean out all
> the crufty "Auto-update from upstream" commits that my workflow generates.
> It's due for another clean-up anyway.

  I put those in a big patch to help people testing the IA64 kdump.=20
People can grab a base kernel and the patch to test.

Thanks
Zou Nan hai


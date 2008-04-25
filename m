From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 25 Apr 2008 01:01:10 +0000
Subject: RE: [2.6 patch] ia64: let NUMA select SMP
Message-Id: <1FE6DD409037234FAB833C420AA843EC012F9FAD@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC012F9EF0@orsmsx424.amr.corp.intel.com> <20080425001652.GD18854@cs181133002.pp.htv.fi> <1FE6DD409037234FAB833C420AA843EC012F9F55@orsmsx424.amr.corp.intel.com> <20080425004139.GE18854@cs181133002.pp.htv.fi>
In-Reply-To: <20080425004139.GE18854@cs181133002.pp.htv.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Adrian Bunk <bunk@kernel.org>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Mike Travis <travis@sgi.com>, Russ Anderson <rja@sgi.com>

> CONFIG_NUMA=3Dy, CONFIG_SMP=3Dn isn't a useful combination, so let NUMA=20
> select SMP.

Yup.  That looks good.  Means that my allnoconfig will now
have SMP=3Dy though :-(  Root of that is selecting GENERIC,
and I'm not sure there is a better choice.

Doesn't change the need for the patch to delete the #if NUMA
clause inside the SMP=3Dn path though (your patch would make my
build work by forcing SMP=3Dy ... so the build error would go
away ... but that doesn't make it OK to have #if NUMA code
inside the SMP=3Dn clause).

This does make we wonder how much dead code is hidden inside
impossibly nested #ifdefs elsewhere in the kernel.

-Tony
=FF=F4=E8=BA{.n=C7+=89=B7=9F=AE=89=AD=86+%=8A=CB=FF=B1=E9=DD=B6=17=A5=8Aw=
=FF=BA{.n=C7+=89=B7=A5=8A{=B1=FE&=BA=E3=F8=A7=B6=17=9B=A1=DC=A8}=A9=9E=B2=
=C6=A0z=DA&j:+v=89=A8=FE=F8=1E=AF=F9=1E=AEw=A5=FE=8A=E02=8A=DE=99=A8=E8=AD=
=DA&=A2)=DF=A1=ABa=B6=DA=FF=FF=FB=E0z=BF=E4z=B9=DE=97=FA+=83=F9=9A=8E=8A=DD=
=A2j=FF=8Aw=E8=FE=1Bf

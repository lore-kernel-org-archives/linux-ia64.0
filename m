From: Alex Shi <alex.shi@linux.alibaba.com>
Date: Sun, 14 Jul 2019 15:21:03 +0000
Subject: Re: [PATCH 01/12] Documentation: move architectures together
Message-Id: <36c522c5-975e-e38e-daad-0f3d9f93b186@linux.alibaba.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190712022018.27989-1-alex.shi@linux.alibaba.com>
 <20190712113427.62fa7ffc@lwn.net>
In-Reply-To: <20190712113427.62fa7ffc@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-stm32@st-md-mailman.stormreply.com, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-omap@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-s390@vger.kernel.org, kvm@vger.kernel.org, linux-sh@vger.kernel.org

Hi Jon,

Thanks for quick response!

=D4=DA 2019/7/13 =C9=CF=CE=E71:34, Jonathan Corbet =D0=B4=B5=C0:
> On Fri, 12 Jul 2019 10:20:07 +0800
> Alex Shi <alex.shi@linux.alibaba.com> wrote:
>=20
>> There are many different archs in Documentation/ dir, it's better to
>> move them together in 'Documentation/arch' which follows from kernel sou=
rce.
>=20
> So this seems certain to collide badly with Mauro's RST-conversion monster
> patch set.

I don't mean that, sorry, and we can figure out if both of them are worthy =
to be picked up.

>=20
> More to the point, though...if we are going to thrash up things this
> badly, we want to be sure that we're doing it right so we don't end up
> renaming everything again.  Grouping stuff into a new arch/ subdirectory
> adds a bit of order, but it doesn't do much toward trying to organize our
> documentation for its readers, and it doesn't help us to modernize the
> docs and get rid of the old, useless stuff.  A quick check shows that many
> of these files have seen no changes other than typo fixes since the
> beginning of the Git era.

Right, there is some docs which need to be update or even drop, and a reord=
er would be a timing to push each of arch maintainer to do something, isn't=
 it? Anyway, reordering  documents like kernel source dir could be one of c=
hoices. :)

>=20
> So, in my mind, this needs some thought.  Maybe we want a
> Documentation/arch in the end, but I'm not convinced that we should just
> create it and fill it with a snow shovel.  This might be a good thing to
> discuss at the kernel summit in September.

Thanks for considering, anyway, it could be a good start to get hands dirty=
 whether the arch dir is needed.=20

Thanks
Alex

From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Tue, 30 Mar 2004 11:20:34 +0000
Subject: Re: Migrate pages from a ccNUMA node to another - patch
Message-Id: <40695802.1F13AB0D@nospam.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4063F581.ACC5C511@nospam.org>
		<1080321646.31638.105.camel@nighthawk>
		<20040330082741.541B77054E@sv1.valinux.co.jp> <20040330.180523.08003015.taka@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, iwamoto@valinux.co.jp

Hirokazu Takahashi wrote:
>=20
> Hello,
>=20
> > > Have you considered any common ground your patch might share with the
> > > people doing memory hotplug?
> > >
> > >     http://people.valinux.co.jp/~iwamoto/mh.html
> > >
> > > They have a similar problem to your migration that occurs when a user
> > > wants to remove a whole or partial NUMA node.
> > > lhms-devel@lists.sourceforge.net
> >
> > Processes must be migrated to other nodes when a node is being
> > removed.  Conversely, processes may be migrated from other nodes when
> > a node is added.  I'm not familiar with NUMA things, and I think our
> > team doesn't have a particular solution.  If you have some idea,
> > that's great.
> >
> > BTW, it seems page migration can use my remap_onepage function.  Our
> > code can move most kinds of pages including hugetlbfs pages and page
> > caches.
>=20
> I believe his patch will interest you since most of the code is
> independent of cpu architecture and it also covers mmaped files,
> shmem, ramdisk, mlocked pages and so on.
>=20
> We will post new version of the memory hotplug patches in a week.
>=20
> Thank you,
> Hirokazu Takahashi.

I am afraid the "remap_onepage()" function + the modifications necessary
at some other places are too much for me :-)

You do a couple of retries, waits. I cannot afford spending so much as
overhead due to some performance optimization.

I can understand that if you want to remove a node / memory module, then you
have to succeed by all means, you have to handle all kinds of pages,
the performance is not at a premium.

Regards,

Zolt=E1n Menyh=E1rt

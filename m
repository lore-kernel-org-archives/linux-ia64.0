From: Hirokazu Takahashi <taka@valinux.co.jp>
Date: Tue, 30 Mar 2004 12:08:04 +0000
Subject: Re: Migrate pages from a ccNUMA node to another - patch
Message-Id: <20040330.210804.71938972.taka@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040330082741.541B77054E@sv1.valinux.co.jp>
	<20040330.180523.08003015.taka@valinux.co.jp>
	<40695802.1F13AB0D@nospam.org>
In-Reply-To: <40695802.1F13AB0D@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Zoltan.Menyhart@bull.net, Zoltan.Menyhart_AT_bull.net@nospam.org
Cc: haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, iwamoto@valinux.co.jp

Hello,

Zolt=E1n Menyh=E1rt wrote:

> > > > Have you considered any common ground your patch might share with t=
he
> > > > people doing memory hotplug?
> > > >
> > > >     http://people.valinux.co.jp/~iwamoto/mh.html
> > > >
> > > > They have a similar problem to your migration that occurs when a us=
er
> > > > wants to remove a whole or partial NUMA node.
> > > > lhms-devel@lists.sourceforge.net
> > >
> > > Processes must be migrated to other nodes when a node is being
> > > removed.  Conversely, processes may be migrated from other nodes when
> > > a node is added.  I'm not familiar with NUMA things, and I think our
> > > team doesn't have a particular solution.  If you have some idea,
> > > that's great.
> > >
> > > BTW, it seems page migration can use my remap_onepage function.  Our
> > > code can move most kinds of pages including hugetlbfs pages and page
> > > caches.
> >=20
> > I believe his patch will interest you since most of the code is
> > independent of cpu architecture and it also covers mmaped files,
> > shmem, ramdisk, mlocked pages and so on.
> >=20
> > We will post new version of the memory hotplug patches in a week.
> >=20
> > Thank you,
> > Hirokazu Takahashi.
>=20
> I am afraid the "remap_onepage()" function + the modifications necessary
> at some other places are too much for me :-)
>=20
> You do a couple of retries, waits. I cannot afford spending so much as
> overhead due to some performance optimization.

I understand what you want to do. Page migration is meaningless if the
cost of it is high.

> I can understand that if you want to remove a node / memory module, then =
you
> have to succeed by all means, you have to handle all kinds of pages,
> the performance is not at a premium.
>=20
> Regards,
>=20
> Zolt=E1n Menyh=E1rt

It's not hard to add "no-retry-mode" to "remap_onepage()" function
if you want. It may skip to migrate some pages if they are accessed
heavily. In paticular if you only want to care about anonymous pages,
they will be handled very well.

Thank you,
Hirokazu Takahashi.

From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Wed, 12 May 2004 11:06:51 +0000
Subject: Re: Who owns those locks ?
Message-Id: <40A2054B.21EDE518@nospam.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F013CCAED@scsmsx401.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Zoltan.Menyhart@bull.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

"Luck, Tony" wrote:
>=20
> >The current task pointers are identity mapped memory addresses.
> >I shift them to the right by 12 bits (these bits are always 0-s).
> >In that way, addresses up to 16 Tbytes can fit into the lock word.
>=20
> Neat trick.  Will work for most people ... but watch out if you
> have an architecture that has sparse physical address space and
> can thus potentially allocate a task structure on a 16TB boundary.
>=20
> At first I thought SGI Altix could be hurt by this, but they are
> saved by the fact that bits [37:36] are always set to one.
>=20
> I know of at least one 1TB machine now, so 16TB machines are only
> a few years away.  You could stretch the life of this patch by
> using PAGE_SHIFT, rather than 12 (as practically nobody builds
> kernels with a 4k pagesize, especially not on monster machines).
>=20
> Or perhaps just fix the allocation of task structures to skip
> around the 16TB aligned ones?
>=20
> -Tony

The first reason to use a shift of 12 bits is:
you can see easily what the address of the owner's task structure is.
In addition, with page size of 16 Kbytes, you've got only 16 Tbytes
in the identity mapped kernel address space any way.
Should we move to a page size of 64 Kbytes, you can use a shift of
16 bits and you keep the address human readable ;-)

Thanks,

Zolt=E1n

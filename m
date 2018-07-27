From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Fri, 27 Jul 2018 20:36:42 +0000
Subject: Re: [ia64:noboot 4/4] mm/page_alloc.c:321:14: error: 'PAGES_PER_SECTION' undeclared; did you mean 'U
Message-Id: <20180727203641.GA17745@rapoport-lnx>
List-Id: <linux-ia64.vger.kernel.org>
References: <201807270703.ixR4vo9j%fengguang.wu@intel.com>
In-Reply-To: <201807270703.ixR4vo9j%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, Jul 27, 2018 at 07:08:40PM +0000, Luck, Tony wrote:
> >> mm/page_alloc.c:321:14: error: 'PAGES_PER_SECTION' undeclared (first u=
se in this function); did you mean 'USEC_PER_SEC'?
>=20
> Weird.  I unpacked that config file and tried to reproduce ... but got a =
clean build.
>=20
> Maybe my build flipped some other options because I'm using an ancient co=
mpiler?
> I noticed this difference at the top of the output when I diffed my .conf=
ig with the
> supplied one:
>=20
> < CONFIG_GCC_VERSION=80100
> ---
> > CONFIG_GCC_VERSION@304
>=20
> Mike: Did you see anything like this when you did cross builds?
=20
Yep, and I think it's not related to the compiler version. Selecting
NO_BOOTMEM allows enabling the DEFERRED_STRUCT_PAGE_INIT option that in
turn causes compilation of the code that uses PAGES_PER_SECTION.  The
definition of PAGES_PER_SECTION, though, depends on SPARSEMEM which is not
enabled in allmconfig for ia64.

I've sent a patch [1] to make DEFERRED_STRUCT_PAGE_INIT depend on
SPARSEMEM, it's landed in the akmp tree.

[1] https://lore.kernel.org/lkml/1530279308-24988-1-git-send-email-rppt@lin=
ux.vnet.ibm.com/#t

> -Tony
>=20
>=20

--=20
Sincerely yours,
Mike.


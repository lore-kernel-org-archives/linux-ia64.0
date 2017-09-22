From: Santosh Sivaraj <santosh@fossix.org>
Date: Fri, 22 Sep 2017 05:46:04 +0000
Subject: Re: [RFC][PATCH v2 0/7] printk/ia64/ppc64/parisc64: let's deprecate %pF/%pf printk specifiers
Message-Id: <20170922053404.3zpfpwetabjut2er@santosiv.in.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="3gqke7d3an37ypbd"
List-Id: <linux-ia64.vger.kernel.org>
References: <20170920162910.32053-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170920162910.32053-1-sergey.senozhatsky@gmail.com>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org


--3gqke7d3an37ypbd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote (on 2017-09-20 16=
:29:02 +0000):

>         Hello
>=20
>         RFC
>=20
>         On some arches C function pointers are indirect and point to
> a function descriptor, which contains the actual pointer to the code.
> This mostly doesn't matter, except for cases when people want to print
> out function pointers in symbolic format, because the usual '%pS/%ps'
> does not work on those arches as expected. That's the reason why we
> have '%pF/%pf', but since it's here because of a subtle ABI detail
> specific to some arches (ppc64/ia64/parisc64) it's easy to misuse
> '%pF/%pf' and '%pS/%ps' (see [1], for example).
>=20
>         This patch set attempts to move ia64/ppc64/parisc64 C function
> pointer ABI details out of printk() to arch code. Function dereference
> code now checks if a pointer belongs to a .opd ELF section and dereferenc=
es
> that pointer only if it does. The kernel and modules have their own .opd
> sections that's why I use two different ARCH functions: for kernel and
> for module pointer dereference.
>=20
>         I planned to remove dereference_function_descriptor() entirely,
> but then I discovered a bunch other uses cases (kgdbts, init/main.c,
> extable, etc.), so I decided to keep dereference_function_descriptor()
> around because the main point of this patch set is to deprecate %pF/%pf.
> But at the same time, I think I can go further and handle both kernel
> and module descriptor dereference in dereference_function_descriptor().
> We need a module pointer for module .opd check, so that will come at an
> extra cost of module lookup (may be there will some other issues along
> the way, haven't checked it).
>=20
> Right now we've got:
>=20
> - dereference_function_descriptor(addr)
>         a generic (old) function. it simply attempts to dereference
>         whatever pointer we give it.
>=20
> - dereference_kernel_function_descriptor(addr)
>         dereferences a kernel pointer if it's within the kernel's .opd
>         section.
>=20
> - dereference_module_function_descriptor(module, addr)
>         dereference a module pointer if it's within the module's .opd
>         section.
>=20
>=20
> *** A BIG NOTE ***
>         I don't own ia64/ppc64/parisc64 hardware, so the patches are not
>         tested. Sorry about that!

Tested patch series on ppc64 sucessfully.

You may add tested by to the series.

Tested-by: Santosh Sivaraj <santosh@fossix.org>

Thanks,
Santosh

>=20
> Another note:
>         I need to check what is BPF symbol lookup and do we need to
>         do any dereference there.
>=20
> v2:
> -- convert dereference_function_descriptor() to unsigned long
> -- fix kernel descriptor range checks (Helge)
> -- fix parisc module descriptor range check (Helge)
> -- fix ppc64 module range check
> -- add checkpatch patch
>=20
>=20
> Sergey Senozhatsky (7):
>   switch dereference_function_descriptor() to `unsigned long'
>   sections: split dereference_function_descriptor()
>   ia64: Add .opd based function descriptor dereference
>   powerpc64: Add .opd based function descriptor dereference
>   parisc64: Add .opd based function descriptor dereference
>   symbol lookup: use new kernel and module dereference functions
>   checkpatch: add pF/pf deprecation warning
>=20
>  Documentation/printk-formats.txt          | 15 +++++----------
>  arch/ia64/include/asm/sections.h          | 16 ++++++++++++----
>  arch/ia64/kernel/module.c                 | 13 +++++++++++++
>  arch/ia64/kernel/vmlinux.lds.S            |  2 ++
>  arch/parisc/boot/compressed/vmlinux.lds.S |  2 ++
>  arch/parisc/include/asm/sections.h        |  4 +++-
>  arch/parisc/kernel/module.c               | 17 +++++++++++++++++
>  arch/parisc/kernel/process.c              | 15 ++++++++++++---
>  arch/parisc/kernel/vmlinux.lds.S          |  2 ++
>  arch/parisc/mm/init.c                     |  4 ++--
>  arch/powerpc/include/asm/module.h         |  3 +++
>  arch/powerpc/include/asm/sections.h       | 17 ++++++++++++++---
>  arch/powerpc/kernel/module_64.c           | 16 ++++++++++++++++
>  arch/powerpc/kernel/vmlinux.lds.S         |  2 ++
>  drivers/misc/kgdbts.c                     |  2 +-
>  include/asm-generic/sections.h            |  8 ++++++--
>  include/linux/moduleloader.h              |  4 ++++
>  init/main.c                               |  2 +-
>  kernel/extable.c                          |  2 +-
>  kernel/kallsyms.c                         |  1 +
>  kernel/module.c                           |  9 ++++++++-
>  lib/vsprintf.c                            |  5 +----
>  scripts/checkpatch.pl                     |  6 ++++--
>  23 files changed, 132 insertions(+), 35 deletions(-)

--=20

--3gqke7d3an37ypbd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJHBAEBCAAxFiEEEPhI2K1zm+w17KotztxEnntb8vcFAlnEoMwTHHNhbnRvc2hA
Zm9zc2l4Lm9yZwAKCRDO3ESee1vy9/yREACtsc+xLsqli2HsZB6P2keSw+mETPQH
LIZsQwpM7NFJl0CunhLUXCJMAlrTcEJzQwSe6r49U4WGCMGA42ZHowOWTPJnXd3l
+jbSpvDg8lTWlwonzZd+TvkYUI7XPKwWULN3S8kxYWXi+3FioLTV1RPWlFreChmV
5tfLASliqeO4M/7coSS/DFWqTtQ2xYuVDPSITR9VeiVZ8z4/6CMw9H4C20XaTjOs
UrxoFinqv6tGjG2cyq3es+PiipYkahVdrwuxqqaxs6ZXJ2tvdVer9EvUmf3MxWsg
RdR2y/mCSKnIHRUCwohxD6bTtqIPq8FZ4f3kzrig8LygJfJOTdS0KedAdBzdAaAI
yk6WIddOwIpCDF/edzOUo3C6YO/CbxtDO9BoXfgberT8aDfQlC2nDQ18nAoKapmk
kNu6h8zUP45HMNiuq1pz/oXbUb3INNNzip9oIdYpS0B437xm6iVIkXnj2f2yWvFK
qrvNmjjvfMOP28KH+0NIXPlnDxeZSBtEjHxJhBAhBD1JhD6prnOEKBVEVG0XhpPm
As5SNjzWc4gcB3I0kWy6vobwZDWiSEAoYTNnQ94DaUvpv+9HUNAMNBn7tGEwCWgP
l8yZJppf0kFd9eYAhMBr9zRtLN9uiS03iim34Pn9xvAzgMUP0A8cv9r5cOGEBL4n
u7B7rmeWpS0iGA==
=kfaZ
-----END PGP SIGNATURE-----

--3gqke7d3an37ypbd--

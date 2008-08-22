From: Pekka Enberg <penberg@cs.helsinki.fi>
Date: Fri, 22 Aug 2008 08:00:10 +0000
Subject: Re: linux-next: ia64 allmodconfig
Message-Id: <1219392010.27392.6.camel@penberg-laptop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080820233526.14c44ea6.akpm@linux-foundation.org>
In-Reply-To: <20080820233526.14c44ea6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, 2008-08-21 at 22:31 -0500, Robin Holt wrote:
> Argh,  I forgot to add the relavent people.
>=20
> Robin
>=20
> On Thu, Aug 21, 2008 at 10:29:31PM -0500, Robin Holt wrote:
> > [holt@robinlt allmodconfig]$ git-bisect good
> > e63352fa06fb8c476e56e51323d80f2e7baee67f is first bad commit
> > commit e63352fa06fb8c476e56e51323d80f2e7baee67f
> > Author: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> > Date:   Tue Aug 19 20:43:26 2008 +0300
> >=20
> >     kmemtrace: SLUB hooks.
> >    =20
> >     This adds hooks for the SLUB allocator, to allow tracing with kmemt=
race.
> >    =20
> >     Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.=
ro>
> >     Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> >=20
> > :040000 040000 913348ac82982bd048439179f5d9e2231cc42ee6 984c6232d4eb257=
d8b31fe104e8731d8d5d6af18 M	include
> > :040000 040000 eca09754017963bda58bc53e2863f59431df0ea7 92bc3efb5a7b9bc=
254f17def2c31b3c0a030122e M	mm
> >=20
> >=20
> > To sum up, This commit when compiled for IA64 using Andrew's gcc 3.4.5
> > cross compiler and allmodconfig results in a build failure with:
> >=20
> > arch/ia64/kernel/built-in.o(.text+0x4852): In function `efi_initialize_=
iomem_resources':
> > /work/git-linus/allmodconfig/arch/ia64/kernel/efi.c:1200: undefined ref=
erence to `__ia64_save_stack_nonlocal'
> > arch/ia64/kernel/built-in.o(.text+0x12992): In function `pfm_context_cr=
eate':
> > /work/git-linus/allmodconfig/arch/ia64/kernel/perfmon.c:2683: undefined=
 reference to `__ia64_save_stack_nonlocal'
> > arch/ia64/kernel/built-in.o(.text+0x1ba22): In function `sys_perfmonctl=
':
> > /work/git-linus/allmodconfig/arch/ia64/kernel/perfmon.c:4808: undefined=
 reference to `__ia64_save_stack_nonlocal'
> > arch/ia64/kernel/built-in.o(.text+0x379a2): In function `dup_state_stac=
k':
> > /work/git-linus/allmodconfig/arch/ia64/kernel/unwind.c:645: undefined r=
eference to `__ia64_save_stack_nonlocal'
> > arch/ia64/kernel/built-in.o(.text+0x37ec2): In function `desc_prologue':
> > /work/git-linus/allmodconfig/arch/ia64/kernel/unwind.c:809: undefined r=
eference to `__ia64_save_stack_nonlocal'
> > arch/ia64/kernel/built-in.o(.text+0x3a822):/work/git-linus/allmodconfig=
/arch/ia64/kernel/unwind_decoder.c:368: more undefined references to `__ia6=
4_save_stack_nonlocal' follow
> >=20
> > With gcc 4.1.2 it compiles fine.

So efi_initialize_iomem_resources calls kzalloc() which calls an inline
kmalloc() function. =EF=BB=BFIs this with our without CONFIG_KMEMTRACE enab=
led?
Any idea what this '__ia64_save_stack_nonlocal' thing is?

Eduard, did you have plans to move the hooks out-of-line as suggested by
Christoph? That patch might "cure" this thing here...

		Pekka


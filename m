From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 15 Oct 2003 00:22:05 +0000
Subject: Re: GENERIC still failing?
Message-Id: <marc-linux-ia64-106617734007194@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106617635106445@msgid-missing>
In-Reply-To: <marc-linux-ia64-106617635106445@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, Oct 14, 2003 at 05:12:17PM -0700, jbarnes wrote:
> On Tue, Oct 14, 2003 at 05:05:14PM -0700, David Mosberger wrote:
> > According to this page:
> >=20
> > 	http://www.gelato.unsw.edu.au/kerncomp/
> >=20
> > GENERIC builds are still failing:
> >=20
> >   gcc -Wp,-MD,fs/ext2/.balloc.o.d -nostdinc -iwithprefix include -D__KE=
RNEL__ -Iinclude   -D__KERNEL__ -Iinclude   -Wall -Wstrict-prototypes -Wno-=
trigraphs -O2 -fno-strict-aliasing -fno-common -pipe  -ffixed-r13 -mfixed-r=
ange=F12-f15,f32-f127 -falign-functions2 -frename-registers -fomit-frame-po=
inter    -mconstant-gp -DKBUILD_BASENAME=BAlloc -DKBUILD_MODNAME=3Dext2 -c =
-o fs/ext2/balloc.o fs/ext2/balloc.c
> > arch/ia64/sn/kernel/setup.c:94: error: `MAX_PHYSNODE_ID' undeclared her=
e (not in a function)
> > arch/ia64/sn/kernel/setup.c:94: error: conflicting types for `physical_=
node_map'
> > include/asm/sn/sn_cpuid.h:126: error: previous declaration of `physical=
_node_map'
> >=20
> > Anybody care to send me a fix for this?

Looks like CONFIG_NUMA and CONFIG_DISCONTIGMEM are missing from the
config being built.  A generic kernel won't work without them.

Jesse

From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 15 Oct 2003 00:12:17 +0000
Subject: Re: GENERIC still failing?
Message-Id: <marc-linux-ia64-106617677006771@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106617635106445@msgid-missing>
In-Reply-To: <marc-linux-ia64-106617635106445@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, Oct 14, 2003 at 05:05:14PM -0700, David Mosberger wrote:
> According to this page:
>=20
> 	http://www.gelato.unsw.edu.au/kerncomp/
>=20
> GENERIC builds are still failing:
>=20
>   gcc -Wp,-MD,fs/ext2/.balloc.o.d -nostdinc -iwithprefix include -D__KERN=
EL__ -Iinclude   -D__KERNEL__ -Iinclude   -Wall -Wstrict-prototypes -Wno-tr=
igraphs -O2 -fno-strict-aliasing -fno-common -pipe  -ffixed-r13 -mfixed-ran=
ge=F12-f15,f32-f127 -falign-functions2 -frename-registers -fomit-frame-poin=
ter    -mconstant-gp -DKBUILD_BASENAME=BAlloc -DKBUILD_MODNAME=3Dext2 -c -o=
 fs/ext2/balloc.o fs/ext2/balloc.c
> arch/ia64/sn/kernel/setup.c:94: error: `MAX_PHYSNODE_ID' undeclared here =
(not in a function)
> arch/ia64/sn/kernel/setup.c:94: error: conflicting types for `physical_no=
de_map'
> include/asm/sn/sn_cpuid.h:126: error: previous declaration of `physical_n=
ode_map'
>=20
> Anybody care to send me a fix for this?

Which tree is this?  Your to-linus-2.5 tree?  Let me know and I'll fix
it.

Jesse

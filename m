From: grundler@cup.hp.com (Grant Grundler)
Date: Thu, 13 Feb 2003 17:53:24 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.60)
Message-Id: <marc-linux-ia64-105590709805840@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, Feb 12, 2003 at 03:26:10PM -0800, David Mosberger wrote:
> An updated ia64 patch is now at:
>=20
>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/linux-2.5.60-ia64-=
030212.diff.gz
>=20

  gcc -Wp,-MD,arch/ia64/mm/.hugetlbpage.o.d -D__KERNEL__ -Iinclude -Wall -W=
strict-prototypes -Wno-trigraphs -g -O2 -fno-strict-aliasing -fno-common -p=
ipe  -ffixed-r13 -mfixed-range=F10-f15,f32-f127 -falign-functions2 -frename=
-registers --param max-inline-insnsP00 -fomit-frame-pointer -nostdinc -iwit=
hprefix include -mconstant-gp   -DKBUILD_BASENAME=3Dhugetlbpage -DKBUILD_MO=
DNAME=3Dhugetlbpage -c -o arch/ia64/mm/hugetlbpage.o arch/ia64/mm/hugetlbpa=
ge.c
  arch/ia64/mm/hugetlbpage.c: In function `set_hugetlb_mem_size':
  arch/ia64/mm/hugetlbpage.c:305: warning: unused variable `j'
  arch/ia64/mm/hugetlbpage.c:306: warning: unused variable `map'
  arch/ia64/mm/hugetlbpage.c: At top level:
  arch/ia64/mm/hugetlbpage.c:405: `zap_hugetlb_resources' undeclared here (=
not in a function)
  arch/ia64/mm/hugetlbpage.c:405: initializer element is not constant
  arch/ia64/mm/hugetlbpage.c:405: (near initialization for `hugetlb_vm_ops.=
close')
  make[1]: *** [arch/ia64/mm/hugetlbpage.o] Error 1
  make: *** [arch/ia64/mm] Error 2

I don't have time to learn about HUGE_TLB and will disable for now.
TPC-C folks will want HUGE_TLB working.

thanks,
grant


From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Mon, 03 Mar 2003 15:37:44 +0000
Subject: Re: [Discontig-devel] Re: [Linux-ia64] Re: 2.5.59 & mmap_sem
Message-Id: <marc-linux-ia64-105590709805955@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805868@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805868@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I tested this one OK on 2.5.60.
Thanks.
Xavier

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


Andrew Morton writes:
 >=20
 > On reflection, I think your approach is best - there is (some) value in =
being
 > able to inherit a /dev/mem mapping across fork(), and ceasing to do so m=
ay
 > break applications.
 >=20
 > I recast your patch a little.  Saves a few instructions and prevents a b=
ogus
 > uninitialised variable warning.
 >=20
 >=20
 > diff -puN mm/memory.c~copy_page_range-invalid-page-fix mm/memory.c
 > --- 25/mm/memory.c~copy_page_range-invalid-page-fix	2003-03-01 17:26:03.=
000000000 -0800
 > +++ 25-akpm/mm/memory.c	2003-03-01 17:26:29.000000000 -0800
 > @@ -286,9 +286,11 @@ skip_copy_pte_range:
 >  					goto cont_copy_pte_range_noset;
 >  				}
 >  				pfn =3D pte_pfn(pte);
 > +				if (!pfn_valid(pfn)) {
 > +					set_pte(dst_pte, pte);
 > +					goto cont_copy_pte_range_noset;
 > +				}
 >  				page =3D pfn_to_page(pfn);
 > -				if (!pfn_valid(pfn))
 > -					goto cont_copy_pte_range;
 >  				if (PageReserved(page))
 >  					goto cont_copy_pte_range;
 > =20
 >=20
 > _
 >=20
 > Xavier Bru  <Xavier.Bru@bull.net> wrote:
 > >
 > > Works OK for us.
 > > Thanks
 > >=20
 > > --=20
 > >=20
 > > _____________________________________________________________________
 > > =20
 > > Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
 > > tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
 > > fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
 > > addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
 > > _____________________________________________________________________
 > >=20
 > > Andrew Morton writes:
 > >  > William Lee Irwin III <wli@holomorphy.com> wrote:
 > >  > >
 > >  > > On Tue, Feb 18, 2003 at 09:46:31AM +0100, Xavier Bru wrote:
 > >  > > > Thanks for your answers.
 > >  > > > You are right, we do not need a page structure for mapping /dev=
/mem in=20
 > >  > > > IO space (I am not a mm expert :-).
 > >  > > > Here after a possible patch that allows the Xserver running on =
the NUMA
 > >  > > > platform. (We had the same problem on Azusa).
 > >  > >=20
 > >  > > Looks perfectly reasonable to me. Other discontig/NUMA implementa=
tions
 > >  > > are likely to run into the same issue.
 > >  > >=20
 > >  > > You might want to send this on to lkml and cc: akpm, he's pretty =
much
 > >  > > the final destination wrt. VM patches and 2.5.
 > >  > >=20
 > >  >=20
 > >  > I'd prefer to do this at the vma level if poss.  Given that mmap_me=
m()
 > >  > has set VM_RESERVED against the VMA, it should be sufficient to do
 > >  >=20
 > >  > diff -puN mm/memory.c~a mm/memory.c
 > >  > --- 25/mm/memory.c~a	2003-02-18 02:40:01.000000000 -0800
 > >  > +++ 25-akpm/mm/memory.c	2003-02-18 02:40:18.000000000 -0800
 > >  > @@ -211,6 +211,9 @@ int copy_page_range(struct mm_struct *ds
 > >  >  	unsigned long cow;
 > >  >  	struct pte_chain *pte_chain =3D NULL;
 > >  > =20
 > >  > +	if (vma->vm_flags & (VM_RESERVED|VM_IO))
 > >  > +		return 0;
 > >  > +
 > >  >  	if (is_vm_hugetlb_page(vma))
 > >  >  		return copy_hugetlb_page_range(dst, src, vma);
 > >  > =20
 > >  > diff -puN fs/hugetlbfs/inode.c~a fs/hugetlbfs/inode.c
 > >  > --- 25/fs/hugetlbfs/inode.c~a	2003-02-18 02:42:47.000000000 -0800
 > >  > +++ 25-akpm/fs/hugetlbfs/inode.c	2003-02-18 02:42:55.000000000 -0800
 > >  > @@ -63,7 +63,7 @@ static int hugetlbfs_file_mmap(struct fi
 > >  >  	down(&inode->i_sem);
 > >  > =20
 > >  >  	UPDATE_ATIME(inode);
 > >  > -	vma->vm_flags |=3D VM_HUGETLB | VM_RESERVED;
 > >  > +	vma->vm_flags |=3D VM_HUGETLB;
 > >  >  	vma->vm_ops =3D &hugetlb_vm_ops;
 > >  >  	ret =3D hugetlb_prefault(mapping, vma);
 > >  >  	len =3D (loff_t)(vma->vm_end - vma->vm_start) +
 > >  >=20
 > >  > _
 > >  > =20
 > >  >=20
 > >  > The semantics (and usage!) of the VM_foo flags are rather vague.  I=
t needs
 > >  > definiton, and an audit.
 > >  >=20
 > >=20
 > >=20
 > > -------------------------------------------------------
 > > This sf.net email is sponsored by:ThinkGeek
 > > Welcome to geek heaven.
 > > http://thinkgeek.com/sf
 > > _______________________________________________
 > > Discontig-devel mailing list
 > > Discontig-devel@lists.sourceforge.net
 > > https://lists.sourceforge.net/lists/listinfo/discontig-devel


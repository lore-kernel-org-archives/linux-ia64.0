From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Tue, 06 Sep 2022 17:13:24 +0000
Subject: Re: [PATCH v2] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <Yxd/tE4EnIqhfd9s@monkey>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220902190357.469512-1-mike.kravetz@oracle.com>
 <3a65e455-ce68-30e2-6e1b-fb8a1917b40d@csgroup.eu>
In-Reply-To: <3a65e455-ce68-30e2-6e1b-fb8a1917b40d@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Baolin Wang <baolin.wang@linux.alibaba.com>, David Hildenbrand <david@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

On 09/05/22 06:34, Christophe Leroy wrote:
>=20
>=20
> Le 02/09/2022 =E0 21:03, Mike Kravetz a =E9crit=A0:
> > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > index fe4944f89d34..275e554dd365 100644
> > --- a/include/linux/hugetlb.h
> > +++ b/include/linux/hugetlb.h
> > @@ -264,6 +255,13 @@ static inline void adjust_range_if_pmd_sharing_pos=
sible(
> >   {
> >   }
> >  =20
> > +static inline struct page *hugetlb_follow_page_mask(struct vm_area_str=
uct *vma,
> > +				unsigned long address, unsigned int flags)
> > +{
> > +	WARN_ON_ONCE(1); /* should never be called if !CONFIG_HUGETLB_PAGE*/
> > +	return ERR_PTR(-EINVAL);
>=20
> This function is called only when is_vm_hugetlb_page() is true.
>=20
> When !CONFIG_HUGETLB_PAGE is_vm_hugetlb_page() always returns false, so=20
> the call to hugetlb_follow_page_mask() should never be compiled in.
>=20
> Use BUILD_BUG() to catch it at buildtime.
>=20

Yes.  My bad as David suggested this previously.
How about we just leave out the function in the !CONFIG_HUGETLB_PAGE case?
We will get build errors without the need for a BUILD_BUG().

> > +}
> > +
> >   static inline long follow_hugetlb_page(struct mm_struct *mm,
> >   			struct vm_area_struct *vma, struct page **pages,
> >   			struct vm_area_struct **vmas, unsigned long *position,

--=20
Mike Kravetz

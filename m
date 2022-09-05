From: David Hildenbrand <david@redhat.com>
Date: Mon, 05 Sep 2022 16:09:04 +0000
Subject: Re: [PATCH] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <362e6361-e2b7-16eb-83c8-203738f7b5d0@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220829234053.159158-1-mike.kravetz@oracle.com>
 <608934d4-466d-975e-6458-34a91ccb4669@redhat.com> <Yw5AOZ/Kc5f3UP+s@monkey>
 <Yw6Bpsow+gUMlHCU@monkey> <739dc825-ece3-a59f-adc5-65861676e0ae@redhat.com>
 <YxJQfGSsbXd3W4m/@monkey> <323fdb0f-c5a5-e0e5-1ff4-ab971bc295cc@redhat.com>
 <c6f3d408-e050-c1dc-9864-c1b2c92369ed@csgroup.eu>
 <5f6a7c6b-5073-f050-8dae-6ee279a8bb0b@redhat.com>
 <ac9ef726-c465-ccec-363e-9cfb60c170e7@csgroup.eu>
 <e54a4004-3de9-7ddf-9368-e98e0dc45425@redhat.com>
 <bb05ac8a-6847-0dcc-1f71-dc7c3f141f11@csgroup.eu>
In-Reply-To: <bb05ac8a-6847-0dcc-1f71-dc7c3f141f11@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Baolin Wang <baolin.wang@linux.alibaba.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

> Yes I think the assumption is correct for user pages hence for GUP.
> 
> By the way the discussion started with PTDUMP. For PTDUMP we need huge
> page directories to be taken into account. And for anything that
> involves kernel pages like VMAP or VMALLOC.

Yes, makes perfect sense to me now that you explained how/where hugepd 
is actually used -- thanks!

-- 
Thanks,

David / dhildenb

From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 01 Mar 2021 08:13:07 +0000
Subject: Re: [PATCH] mm: Generalize HUGETLB_PAGE_SIZE_VARIABLE
Message-Id: <d5fc741d-0c24-5b0f-c9b3-3a2be796ad79@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1614577853-7452-1-git-send-email-anshuman.khandual@arm.com>
 <20210301062358.GA25761@lst.de>
 <89f2d77c-f4bc-8f7b-a6b0-1c04e422fb77@arm.com>
 <20210301075352.GA27659@lst.de>
In-Reply-To: <20210301075352.GA27659@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org



On 3/1/21 1:23 PM, Christoph Hellwig wrote:
> On Mon, Mar 01, 2021 at 01:13:41PM +0530, Anshuman Khandual wrote:
>>> doesn't this need a 'if HUGETLB_PAGE'
>>
>> While making HUGETLB_PAGE_SIZE_VARIABLE a generic option, also made it
>> dependent on HUGETLB_PAGE. Should not that gate HUGETLB_PAGE_SIZE_VARIABLE
>> when HUGETLB_PAGE is not available irrespective of the select statement on
>> the platforms ?
> 
> depends doesn't properly work for variables that are selected.
> 

Alright, will move the HUGETLB_PAGE dependency to platforms while selecting
the variable HUGETLB_PAGE_SIZE_VARIABLE.

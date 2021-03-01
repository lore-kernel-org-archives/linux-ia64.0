From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 01 Mar 2021 07:55:41 +0000
Subject: Re: [PATCH] mm: Generalize HUGETLB_PAGE_SIZE_VARIABLE
Message-Id: <89f2d77c-f4bc-8f7b-a6b0-1c04e422fb77@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1614577853-7452-1-git-send-email-anshuman.khandual@arm.com>
 <20210301062358.GA25761@lst.de>
In-Reply-To: <20210301062358.GA25761@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org



On 3/1/21 11:53 AM, Christoph Hellwig wrote:
> On Mon, Mar 01, 2021 at 11:20:53AM +0530, Anshuman Khandual wrote:
>> HUGETLB_PAGE_SIZE_VARIABLE need not be defined for each individual
>> platform subscribing it. Instead just make it generic.
>>
>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> Cc: Paul Mackerras <paulus@samba.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Christoph Hellwig <hch@lst.de>
>> Cc: linux-ia64@vger.kernel.org
>> Cc: linuxppc-dev@lists.ozlabs.org
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>> Suggested-by: Christoph Hellwig <hch@lst.de>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>> This change was originally suggested in an earilier discussion. This
>> applies on v5.12-rc1 and has been build tested on all applicable
>> platforms i.e ia64 and powerpc.
>>
>> https://patchwork.kernel.org/project/linux-mm/patch/1613024531-19040-3-git-send-email-anshuman.khandual@arm.com/
>>
>>  arch/ia64/Kconfig    | 6 +-----
>>  arch/powerpc/Kconfig | 6 +-----
>>  mm/Kconfig           | 8 ++++++++
>>  3 files changed, 10 insertions(+), 10 deletions(-)
>>
>> diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
>> index 2ad7a8d29fcc..6b3e3f6c29ae 100644
>> --- a/arch/ia64/Kconfig
>> +++ b/arch/ia64/Kconfig
>> @@ -32,6 +32,7 @@ config IA64
>>  	select TTY
>>  	select HAVE_ARCH_TRACEHOOK
>>  	select HAVE_VIRT_CPU_ACCOUNTING
>> +	select HUGETLB_PAGE_SIZE_VARIABLE
> 
> doesn't this need a 'if HUGETLB_PAGE'

While making HUGETLB_PAGE_SIZE_VARIABLE a generic option, also made it
dependent on HUGETLB_PAGE. Should not that gate HUGETLB_PAGE_SIZE_VARIABLE
when HUGETLB_PAGE is not available irrespective of the select statement on
the platforms ?

> 
> or did you verify that HUGETLB_PAGE_SIZE_VARIABLE checks are always
> nested inside of HUGETLB_PAGE ones?
>

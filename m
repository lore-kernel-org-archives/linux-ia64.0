From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Tue, 02 Mar 2021 07:09:32 +0000
Subject: Re: [PATCH V2] mm: Generalize HUGETLB_PAGE_SIZE_VARIABLE
Message-Id: <4452b859-9e72-974c-95b3-9c70c54472d1@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1614661987-23881-1-git-send-email-anshuman.khandual@arm.com>
 <a3772544-1e84-1969-b71c-ea2a3d013471@csgroup.eu>
 <c33fe839-82c6-d0cd-32d6-b386d143ac51@arm.com>
In-Reply-To: <c33fe839-82c6-d0cd-32d6-b386d143ac51@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Christoph Hellwig <hch@lst.de>



Le 02/03/2021 à 07:37, Anshuman Khandual a écrit :
> 
> 
> On 3/2/21 11:13 AM, Christophe Leroy wrote:
>>
>>
>> Le 02/03/2021 à 06:13, Anshuman Khandual a écrit :
>>> HUGETLB_PAGE_SIZE_VARIABLE need not be defined for each individual
>>> platform subscribing it. Instead just make it generic.
>>>
>>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>>> Cc: Paul Mackerras <paulus@samba.org>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Christoph Hellwig <hch@lst.de>
>>> Cc: linux-ia64@vger.kernel.org
>>> Cc: linuxppc-dev@lists.ozlabs.org
>>> Cc: linux-mm@kvack.org
>>> Cc: linux-kernel@vger.kernel.org
>>> Suggested-by: Christoph Hellwig <hch@lst.de>
>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>> ---
>>> This change was originally suggested in an earilier discussion. This
>>> applies on v5.12-rc1 and has been build tested on all applicable
>>> platforms i.e ia64 and powerpc.
>>>
>>> https://patchwork.kernel.org/project/linux-mm/patch/1613024531-19040-3-git-send-email-anshuman.khandual@arm.com/
>>>
>>> Changes in V2:
>>>
>>> - Added a description for HUGETLB_PAGE_SIZE_VARIABLE
>>
>> You are doing more than adding a description: you are making it user selectable. Is that what you want ?
> 
> No, this was unintended. Will drop that description.
> 

The description in the help section is OK.

It is only the text after the "bool" that makes it selectable.

	bool "Allows dynamic pageblock_order"

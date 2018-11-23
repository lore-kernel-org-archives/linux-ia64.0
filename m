From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Fri, 23 Nov 2018 11:28:00 +0000
Subject: Re: [PATCH] mm: Replace all open encodings for NUMA_NO_NODE
Message-Id: <2c0e9cef-663b-553c-e25e-63f7da59ab63@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1542966856-12619-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1542966856-12619-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, akpm@linux-foundation.org, jiangqi903@gmail.com, hverkuil@xs4all.nl

min

On 11/23/2018 04:06 PM, David Hildenbrand wrote:
> On 23.11.18 10:54, Anshuman Khandual wrote:
>> At present there are multiple places where invalid node number is encoded
>> as -1. Even though implicitly understood it is always better to have macros
>> in there. Replace these open encodings for an invalid node number with the
>> global macro NUMA_NO_NODE. This helps remove NUMA related assumptions like
>> 'invalid node' from various places redirecting them to a common definition.
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>>
>> Changes in V1:
>>
>> - Dropped OCFS2 changes per Joseph
>> - Dropped media/video drivers changes per Hans
>>
>> RFC - https://patchwork.kernel.org/patch/10678035/
>>
>> Build tested this with multiple cross compiler options like alpha, sparc,
>> arm64, x86, powerpc, powerpc64le etc with their default config which might
>> not have compiled tested all driver related changes. I will appreciate
>> folks giving this a test in their respective build environment.
>>
>> All these places for replacement were found by running the following grep
>> patterns on the entire kernel code. Please let me know if this might have
>> missed some instances. This might also have replaced some false positives.
>> I will appreciate suggestions, inputs and review.
>>
>> 1. git grep "nid = -1"
>> 2. git grep "node = -1"
>> 3. git grep "nid = -1"
>> 4. git grep "node = -1"
> 
> Hopefully you found most users :)

I hope so :)

> 
> Did you check if some are encoded into function calls? f(-1, ...)

Not really. Just wondering how do we even search for it. There might be
higher level functions passing down -1 to core MM. If you have some
instances in mind which need replacement I will accommodate them.

> 
> Reviewed-by: David Hildenbrand <david@redhat.com>

Thanks for the review.

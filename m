From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 12 Nov 2018 11:59:19 +0000
Subject: Re: [RFC] mm: Replace all open encodings for NUMA_NO_NODE
Message-Id: <d947edec-8c5a-78d7-4069-687ac4ad7cb8@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1541990515-11670-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1541990515-11670-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Verkuil <hverkuil@xs4all.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org



On 11/12/2018 02:13 PM, Hans Verkuil wrote:
> On 11/12/2018 03:41 AM, Anshuman Khandual wrote:
>> At present there are multiple places where invalid node number is encoded
>> as -1. Even though implicitly understood it is always better to have macros
>> in there. Replace these open encodings for an invalid node number with the
>> global macro NUMA_NO_NODE. This helps remove NUMA related assumptions like
>> 'invalid node' from various places redirecting them to a common definition.
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>> Build tested this with multiple cross compiler options like alpha, sparc,
>> arm64, x86, powerpc64le etc with their default config which might not have
>> compiled tested all driver related changes. I will appreciate folks giving
>> this a test in their respective build environment.
>>
>> All these places for replacement were found by running the following grep
>> patterns on the entire kernel code. Please let me know if this might have
>> missed some instances. This might also have replaced some false positives.
>> I will appreciate suggestions, inputs and review.
> The 'node' in the drivers/media and the drivers/video sources has nothing to
> do with numa. It's an index for a framebuffer instead (i.e. the X in /dev/fbX).

Thanks for the input. Will drop the changes there.

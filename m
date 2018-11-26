From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 26 Nov 2018 06:57:04 +0000
Subject: Re: [PATCH] mm: Replace all open encodings for NUMA_NO_NODE
Message-Id: <5228bcdb-b140-a86a-6c9c-488f1a723353@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1542966856-12619-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1542966856-12619-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vinod Koul <vkoul@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, akpm@linux-foundation.org, jiangqi903@gmail.com, hverkuil@xs4all.nl



On 11/24/2018 07:35 PM, Vinod Koul wrote:
> On 23-11-18, 15:24, Anshuman Khandual wrote:
> 
>> --- a/drivers/dma/dmaengine.c
>> +++ b/drivers/dma/dmaengine.c
>> @@ -386,7 +386,8 @@ EXPORT_SYMBOL(dma_issue_pending_all);
>>  static bool dma_chan_is_local(struct dma_chan *chan, int cpu)
>>  {
>>  	int node = dev_to_node(chan->device->dev);
>> -	return node = -1 || cpumask_test_cpu(cpu, cpumask_of_node(node));
>> +	return node = NUMA_NO_NODE ||
>> +		cpumask_test_cpu(cpu, cpumask_of_node(node));
>>  }
> 
> I do not see dev_to_node being updated first, that returns -1 so I would
> prefer to check for -1 unless it return NUMA_NO_NODE

Sure will update dev_to_node() to return NUMA_NO_NODE as well.

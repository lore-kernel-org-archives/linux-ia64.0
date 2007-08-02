From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 02 Aug 2007 21:56:56 +0000
Subject: RE: ia64 mmu_gather question
Message-Id: <617E1C2C70743745A92448908E030B2A021570D3@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186026055.5495.585.camel@localhost.localdomain>
In-Reply-To: <1186026055.5495.585.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> So I suspect at this stage that the race isn't affecting you. However,
> it looks to me that you put the burden on the fairly hot TLB miss path
> rather than on the much less hot invalidation path itself...

Suggestions on how to do move the burden gratefully received.  I don't
think that it is all that bad though.  The re-read of the PGD>PUD>PMD>PTE
should all hit in the L1-D cache, which has single cycle latency.

-Tony

From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 12 Nov 2018 04:22:39 +0000
Subject: Re: [RFC] mm: Replace all open encodings for NUMA_NO_NODE
Message-Id: <b92e3275-7a04-a148-bb5b-38658c270583@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1541990515-11670-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1541990515-11670-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joseph Qi <jiangqi903@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org



On 11/12/2018 09:27 AM, Joseph Qi wrote:
> For ocfs2 part, node means host in the cluster, not NUMA node.
> 

Does not -1 indicate an invalid node which can never be present ?

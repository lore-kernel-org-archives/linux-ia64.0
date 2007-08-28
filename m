From: Adam Litke <agl@us.ibm.com>
Date: Tue, 28 Aug 2007 22:41:40 +0000
Subject: Re: [PATCH] Fix find_next_best_node (Re: [BUG] 2.6.23-rc3-mm1
Message-Id: <1188340900.15336.84.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A023EB020@scsmsx411.amr.corp.intel.com>
	 <20070823142133.9359a1ce.akpm@linux-foundation.org>
	 <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, "Luck, Tony" <tony.luck@intel.com>, Jeremy Higdon <jeremy@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org

On Fri, 2007-08-24 at 15:53 +0900, Yasunori Goto wrote:
> I found find_next_best_node() was wrong.
> I confirmed boot up by the following patch.
> Mel-san, Kamalesh-san, could you try this?

FYI: This patch also allows the alloc-instantiate-race testcase in
libhugetlbfs to pass again :)

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center


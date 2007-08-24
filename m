From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 24 Aug 2007 17:00:35 +0000
Subject: Re: [PATCH] Fix find_next_best_node (Re: [BUG] 2.6.23-rc3-mm1 Kernel
Message-Id: <Pine.LNX.4.64.0708240957010.20501@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A023EB020@scsmsx411.amr.corp.intel.com>
  <20070823142133.9359a1ce.akpm@linux-foundation.org> 
 <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>  <20070824145233.GA26374@skynet.ie>
 <1187970572.5869.10.camel@localhost>
In-Reply-To: <1187970572.5869.10.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@skynet.ie>, Yasunori Goto <y-goto@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, "Luck, Tony" <tony.luck@intel.com>, Jeremy Higdon <jeremy@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Fri, 24 Aug 2007, Lee Schermerhorn wrote:

> I reworked that patch and posted the update on 16aug which does not have
> this problem:
> 
> http://marc.info/?l=linux-mm&m8729871101418&w=4
> 
> This should replace
> memoryless-nodes-fixup-uses-of-node_online_map-in-generic-code.patch
> in -mm.

Could you post a diff to rc3-mm1 of that patch?


From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 15 Dec 2004 00:28:04 +0000
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <41BF8514.1030208@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F028C1639@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F028C1639@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, ak@suse.de, Yasunori Goto <ygoto@us.fujitsu.com>

Luck, Tony wrote:
>>this behavior is turned on by default only for IA64 NUMA systems
> 
> 
>>A boot line parameter "hashdist" can be set to override the default
>>behavior.
> 
> 
> 
> Note to node hot-plug developers ... if this patch goes in you
> will also want to disable this behaviour, otherwaise all nodes
> become non-removeable (unless you can transparently re-locate the
> physical memory backing all these tables).
(adding CC to LHMS)

I think GFP_HOTREMOVABLE , which Goto is proposing, will work well
when we want MEMORY_HOTPLUG.


Thnaks.
--Kame <kamezawa.hiroyu@jp.fujitsu.com>

 >
 > -Tony



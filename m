From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 07 Oct 2004 23:38:24 +0000
Subject: Re: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
Message-Id: <4165D370.1090208@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0226680C@scsmsx401.amr.corp.intel.com>
 <4164E20D.5020400@jp.fujitsu.com> <1248570000.1097159887@[10.10.2.4]>
In-Reply-To: <1248570000.1097159887@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>


Martin J. Bligh wrote:
> The normal way to fix the above is just to have a bitmap array to test - 
> in your case a 1GB granularity would be sufficicent. That takes < 1 word
> to implement for the example above ;-)
> 
> M.
> 

Although I don't like a page fault, I now understand it doesn't often happen.
I'd like to use current implementation.

Thanks

Kame <kamezawa.hiroyu@jp.fujitsu.com>

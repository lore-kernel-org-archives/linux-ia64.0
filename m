From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 20 Oct 2006 16:20:12 +0000
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
Message-Id: <20061020162012.GA24338@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0610190932310.8072@schroedinger.engr.sgi.com> <20061020101857.b795f143.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0610191838420.11820@schroedinger.engr.sgi.com> <20061020110618.6423d0e4.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0610191925180.12581@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610191925180.12581@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Thu, Oct 19, 2006 at 07:26:33PM -0700, Christoph Lameter wrote:
> On Fri, 20 Oct 2006, KAMEZAWA Hiroyuki wrote:
> 
> > By the way, we have to make sizeof(struct page) as (1 << x) aligned size to use
> > large-sized page. (IIRC, my gcc-3.4.3 says it is 56bytes....)
> 
> Having it 1 << x would be useful to simplify the pfn_valid check but 
> you can also check the start and the end of the page struct to allow the 
> page struct cross a page boundary. See the ia64 virtual memmap 
> implementation of pfn_valid.

Rounding up sizeof(struct page) to a power of two would have to provide
a huge benefit somewhere to outweigh the cost of doing so.  With a 16K
page size there are 64K pages/gigabyte ... so adding an 8 byte pad now would
waste an extra 0.5M per gigabyte of memory (which adds up to 2G on SGI's
monster 4TB machines).  That's pretty bad ... but if we ever added anything
new to struct page and pushed it just over 64bytes, it would be a complete
disaster to round up to 128!!!

Listen to Christoph.  Check the start and end address of the page struct in
pfn_valid.

-Tony

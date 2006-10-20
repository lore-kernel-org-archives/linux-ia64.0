From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 20 Oct 2006 02:26:33 +0000
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
Message-Id: <Pine.LNX.4.64.0610191925180.12581@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610190932310.8072@schroedinger.engr.sgi.com>
 <20061020101857.b795f143.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610191838420.11820@schroedinger.engr.sgi.com>
 <20061020110618.6423d0e4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061020110618.6423d0e4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Fri, 20 Oct 2006, KAMEZAWA Hiroyuki wrote:

> By the way, we have to make sizeof(struct page) as (1 << x) aligned size to use
> large-sized page. (IIRC, my gcc-3.4.3 says it is 56bytes....)

Having it 1 << x would be useful to simplify the pfn_valid check but 
you can also check the start and the end of the page struct to allow the 
page struct cross a page boundary. See the ia64 virtual memmap 
implementation of pfn_valid.


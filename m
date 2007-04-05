From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 05 Apr 2007 22:27:00 +0000
Subject: Re: [PATCH 1/4] Generic Virtual Memmap suport for SPARSEMEM V3
Message-Id: <Pine.LNX.4.64.0704051525350.15901@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070404230619.20292.4475.sendpatchset@schroedinger.engr.sgi.com>
 <20070405.142900.59466568.davem@davemloft.net>
In-Reply-To: <20070405.142900.59466568.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mbligh@google.com, linux-mm@kvack.org, ak@suse.de, hansendc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com

On Thu, 5 Apr 2007, David Miller wrote:

> Hey Christoph, here is sparc64 support for this stuff.

Great!

> After implementing this and seeing more and more how it works, I
> really like it :-)
> 
> Thanks a lot for doing this work Christoph!

Thanks for the appreciation. CCing Andy Whitcroft who will hopefully 
merge this all of this together into sparsemem including the S/390 
implementation.



From: Andy Whitcroft <apw@shadowen.org>
Date: Tue, 10 Apr 2007 10:43:43 +0000
Subject: Re: [PATCH 1/4] Generic Virtual Memmap suport for SPARSEMEM V3
Message-Id: <461B6A5F.3020007@shadowen.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070404230619.20292.4475.sendpatchset@schroedinger.engr.sgi.com> <20070405.142900.59466568.davem@davemloft.net> <Pine.LNX.4.64.0704051525350.15901@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704051525350.15901@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mbligh@google.com, linux-mm@kvack.org, ak@suse.de, hansendc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com

Christoph Lameter wrote:
> On Thu, 5 Apr 2007, David Miller wrote:
> 
>> Hey Christoph, here is sparc64 support for this stuff.
> 
> Great!
> 
>> After implementing this and seeing more and more how it works, I
>> really like it :-)
>>
>> Thanks a lot for doing this work Christoph!
> 
> Thanks for the appreciation. CCing Andy Whitcroft who will hopefully 
> merge this all of this together into sparsemem including the S/390 
> implementation.

Yep grabbed this one and added it to the stack.  Now to find a sparc to
test it with!

-apw

From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 13 Mar 2007 01:38:32 +0000
Subject: Re: [QUICKLIST 0/6] Arch independent quicklists V1
Message-Id: <Pine.LNX.4.64.0703121833490.28836@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
 <20070312.155157.74747634.davem@davemloft.net> <17909.62028.117035.287313@cargo.ozlabs.ibm.com>
In-Reply-To: <17909.62028.117035.287313@cargo.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Mackerras <paulus@samba.org>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, ak@suse.com, holt@sgi.com, linux-ia64@vger.kernel.org, mpm@selenic.com

On Tue, 13 Mar 2007, Paul Mackerras wrote:

> Also, I didn't understand why we have to do quicklists to take
> advantage of the fact that the pages are in a pristine state when they
> are freed.  I thought the whole point of the slab allocator was to be
> able to take advantage of that...

It used to be the case that initializating objects was better in the past. 
Today it is better to initialize the objects immediately before they are 
used. That will move them into the cpu caches and keep them there. 
Initializing them earlier may cause the cachelines of the object to be 
evicted from the cpu cache and then those have to be refetched. The 
benefit of this approach diminishes the larger objects get and the sparser 
the access to the cachelines of the object. In the case of page sized 
objects that are sparsely accessed (the PAGE_SIZE caches covered by 
quicklists) it makes sense to attempt to avoid having to touch all 
cachelines of the page on alloc.



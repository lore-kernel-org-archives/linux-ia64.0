From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 03 Mar 2005 05:24:52 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <42269FA4.5020009@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com>	<20050302174507.7991af94.akpm@osdl.org>	<Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>	<20050302185508.4cd2f618.akpm@osdl.org>	<Pine.LNX.4.58.0503021856380.3365@schroedinger.engr.sgi.com> <20050302201425.2b994195.akpm@osdl.org>
In-Reply-To: <20050302201425.2b994195.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Andrew Morton wrote:

>Christoph Lameter <clameter@sgi.com> wrote:
>
>>On Wed, 2 Mar 2005, Andrew Morton wrote:
>>
>>
>>>>Earlier releases back in September 2004 had some pte locking code (and
>>>>AFAIK Nick also played around with pte locking) but that
>>>>was less efficient than atomic operations.
>>>>
>>>How much less efficient?
>>>Does anyone else have that code around?
>>>
>>Nick may have some data. It got far too complicated too fast when I tried
>>to introduce locking for individual ptes. It required bit
>>spinlocks for the pte meaning multiple atomic operations.
>>
>
>One could add a spinlock to the pageframe, or use hashed spinlocking.
>
>

I did have a version using bit spin locks in the pte on ia64. That
only works efficiently on architectures who's MMU hardware won't
concurrently update the pte (so you can do non-atomic pte operations
and non-atomic unlocks on a locked pte).

I pretty much solved all the efficiency problems IIRC. Of course
this doesn't work on i386 or x86_64.

Having a spinlock for example per pte page might be another good
option that we haven't looked at.

>>One
>>would have to check for the lock being active leading to significant code
>>changes.
>>
>
>Why?
>
>

When using per-pte locks on ia64 for example, the low level code that
walks page tables and sets dirty, accessed, etc bits needs to be made
aware of the pte lock. But Keith made me up a little patch to do this,
and it is pretty simple.



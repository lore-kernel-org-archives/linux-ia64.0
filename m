From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 04 Apr 2006 01:05:43 +0000
Subject: Re: Fix ia64 bit ops: Full barriers for bit operations returning
Message-Id: <4431C667.7090301@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:

>Christoph Lameter wrote on Monday, April 03, 2006 11:33 AM
>
>>
>>Note that this only fixes up the bit operations if used together with the
>>earlier fix for the clear_bit barriers. We still need a fix for general 
>>atomic operations.
>>
>>Signed-off-by: Christoph Lameter <clameter@sgi.com>
>>
>
>
>Looks good to me.
>Acked-by: Ken Chen <kenneth.w.chen@intel.com>
>

I don't think my concern about this approach was ever answered: an
acquire + release combination will always allow memory operations to
move past the atomic operation, won't it?

I would have thought you'd need release + acquire.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

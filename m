From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 03 Mar 2005 07:44:24 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <4226C058.4080108@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com>	 <Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com>	 <20050302174507.7991af94.akpm@osdl.org>	 <Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>	 <20050302185508.4cd2f618.akpm@osdl.org>	 <Pine.LNX.4.58.0503021856380.3365@schroedinger.engr.sgi.com>	 <20050302201425.2b994195.akpm@osdl.org>	 <16934.39386.686708.768378@cargo.ozlabs.ibm.com>	 <20050302213831.7e6449eb.davem@davemloft.net>	 <1109829248.5679.178.camel@gaston>  <42274727.2070200@yahoo.com.au> <1109831428.5680.187.camel@gaston>
In-Reply-To: <1109831428.5680.187.camel@gaston>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "David S. Miller" <davem@davemloft.net>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@osdl.org>, clameter@sgi.com, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Anton Blanchard <anton@samba.org>

Benjamin Herrenschmidt wrote:
> On Fri, 2005-03-04 at 04:19 +1100, Nick Piggin wrote:
> 
> 
>>You don't want to do that for all architectures, as I said earlier.
>>eg. i386 can concurrently set the dirty bit with the MMU (which won't
>>honour the lock).
>>
>>So you then need an atomic lock, atomic pte operations, and atomic
>>unlock where previously you had only the atomic pte operation. This is
>>disastrous for performance.
> 
> 
> Of course, but I was answering to David about sparc64 which uses
> software TLB load :)
> 

Oh sorry, I completely misunderstood what you said... and the
context in which you said it :P


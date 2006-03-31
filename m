From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 31 Mar 2006 02:53:21 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <442C99A1.6060901@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603310244.k2V2iQg28203@unix-os.sc.intel.com>
In-Reply-To: <200603310244.k2V2iQg28203@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Christoph Lameter' <clameter@sgi.com>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> Christoph Lameter wrote on Thursday, March 30, 2006 6:38 PM
> 
>>>>Neither one is correct because there will always be one combination of 
>>>>clear_bit with these macros that does not generate the required memory 
>>>>barrier.
>>>
>>>Can you give an example?  Which combination?
>>
>>For Option(1)
>>
>>smp_mb__before_clear_bit()
>>clear_bit(...)(
> 
> 
> Sorry, you totally lost me.  It could me I'm extremely slow today.  For
> option (1), on ia64, clear_bit has release semantic already.  The comb
> of __before_clear_bit + clear_bit provides the required ordering.  Did
> I miss something?  By the way, we are talking about detail implementation
> on one specific architecture.  Not some generic concept that clear_bit
> has no ordering stuff in there.
> 

The memory ordering that above combination should produce is a
Linux style smp_mb before the clear_bit. Not a release.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

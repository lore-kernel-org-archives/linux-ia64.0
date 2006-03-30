From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 30 Mar 2006 08:55:52 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <442B9D18.4050903@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <65953E8166311641A685BDF71D865826A23D40@cacexc12.americas.cpqcorp.net> <Pine.LNX.4.64.0603291529160.26011@schroedinger.engr.sgi.com> <442B9A2A.7000306@bull.net>
In-Reply-To: <442B9A2A.7000306@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: Christoph Lameter <clameter@sgi.com>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Zoltan Menyhart wrote:

> However, I do not think your implementation would be efficient due to
> selecting the ordering mode at run time:
> 
>> +    switch (mode) {
>> +    case MODE_NONE :
>> +    case MODE_ACQUIRE :
>> +        return cmpxchg_acq(m, old, new);
>> +    case MODE_FENCE :
>> +        smp_mb();
>> +        /* Fall through */
>> +    case MODE_RELEASE :
>> +        return cmpxchg_rel(m, old, new);
> 

BTW. Isn't MODE_FENCE wrong? Seems like a read or write could be moved
above cmpxchg_rel?

I think you need rel+acq rather than acq+rel (if I'm right, then the
same goes for your earlier bitops patches, btw).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

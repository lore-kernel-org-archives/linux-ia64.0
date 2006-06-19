From: Andi Kleen <ak@suse.de>
Date: Mon, 19 Jun 2006 08:54:29 +0000
Subject: Re: [discuss] Re: FOR REVIEW: New x86-64 vsyscall vgetcpu()
Message-Id: <200606191054.29543.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606140942.31150.ak@suse.de> <200606170855.49123.ak@suse.de> <44966383.1030006@bull.net>
In-Reply-To: <44966383.1030006@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: discuss@x86-64.org, Chase Venters <chase.venters@clientec.com>, Brent Casavant <bcasavan@sgi.com>, Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, libc-alpha@sourceware.org, vojtech@suse.cz, linux-ia64@vger.kernel.org


> Probably I have not explained it correctly:
> - The "information page" (that includes the current CPU no.) is not a
>   per CPU page

If it isn't then you can't figure out the current CPU/node for a thread.

Anyways I think we're talking past each other. Your approach might
even work on ia64 (at least if you're willing to add a lot of cost
to the context switch). You presumably could implement vgetcpu()
internally with an approach like this (although with IA64's fast 
EPC calls it seems a bit pointless) 

It just won't work on x86. 

-Andi

From: Rohit Seth <rohitseth@google.com>
Date: Sat, 28 Apr 2007 18:17:45 +0000
Subject: RE: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <200704281817.l3SIHu0P001764@smtp.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0704280620150.9554@blonde.wat.veritas.com>
References: <20070426001615.GA8908@ldl.fc.hp.com>
In-Reply-To: <20070426001615.GA8908@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Hugh Dickins' <hugh@veritas.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Mike Stroyan' <mike.stroyan@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "'Luck, Tony'" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

 Hi Hugh,

-----Original Message-----
From: Hugh Dickins [mailto:hugh@veritas.com] 
Sent: Friday, April 27, 2007 10:34 PM
To: Rohit Seth
Cc: Nick Piggin; Mike Stroyan; Andrew Morton; Luck, Tony;
linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path

On Fri, 27 Apr 2007, Rohit Seth wrote:

> lazy_mmu_prot_update was added specifically for notifying change in 
> protection.  So, in a way it is closer to update_mmu_cache (Which is 
> for change in mappings itself).  Though for ia64 implementation, this 
> ends up flushing the icaches when needed.

>The ia64 implementation is the only one which has any use for it, 

Even Itanium didn't need it for almost 5 years :)  Though I think archs that
have incoherent I & D caches could be (theoritically) exposed to same
(original) mprotect code path bug that triggered this API.

>and 
>it's only interested when it's executable i.e. "lazy_mmu_prot_update"
>is a name concealing some overdesign.

You are right that ia64 is only interested in whne the execute permissions
kick in (and FWIW ia64 used to use update_mmu_cache API to do what it is now
doing lazy_mmu_prot_update).  Though the idea was to design an API that any
arch can use to know when ever there is change in protections on a mapping.

Cheers,
-rohit



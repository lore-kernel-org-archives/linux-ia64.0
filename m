From: Hugh Dickins <hugh@veritas.com>
Date: Wed, 24 Nov 2004 16:41:58 +0000
Subject: Re: [PATCH 1/2] setup_arg_pages can insert overlapping vma
Message-Id: <Pine.LNX.4.44.0411241631310.5118-100000@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20041124152250.GA4797@mschwid3.boeblingen.de.ibm.com>
References: <894E37DECA393E4D9374E0ACBBE7427013C9AB@pdsmsx402.ccr.corp.intel.com>
In-Reply-To: <894E37DECA393E4D9374E0ACBBE7427013C9AB@pdsmsx402.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: akpm@osdl.org, nanhai.zou@intel.com, chrisw@osdl.org, torvalds@osdl.org, tony.luck@intel.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 24 Nov 2004, Martin Schwidefsky wrote:
> 
> In principle the patch is fine (it works and fixes a problem).
> 
> I tried to find out why s390 needs its own setup_arg_pages32 function.
> After I've compared the function with the common setup_arg_pages several
> times and still couldn't find a reason for it I just removed the function.
> Still works fine. I think the reason to introduce setup_arg_pages32 has
> been the STACK_TOP define which needs to reflect the smaller address
> space for 31 bit programs. Since the change that made TASK_SIZE look
> at the TIF_31BIT bit to return the correct value for 31 and 64 bit
> programs STACK_TOP is just correct as well. 
> 
> In short, just remove setup_arg_pages32.

Tell me I'm being silly, Martin, but wouldn't it be wiser to stick with
setup_arg_pages32 (with Nanhai's patch) for 2.6.10, then remove it after?

I'm cautious here because about six months ago I sent Andrew a patch
which eliminated setup_arg_pages32 (or equiv) from the three arches,
but the x86_64 one just wouldn't boot on Andrew's machine.  Both hch
and I spent hours staring at the code, neither of us could work out why.

Now, s390 may be greatly superior ;) but all the setup_arg_pages32
redefining is twisty weird stuff - good to be rid of it, but right now?

Hugh


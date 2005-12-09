From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 09 Dec 2005 18:22:09 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <4399CB51.4090405@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>I'm not thrilled about this approach.
>>
>>I'd *like* to be able to assume that "changes in arch/ia64/sn/* clearly
>>don't affect non-SN platforms".  But this style breaks that.  Every ia64
>>box calls all these SN init functions, and if somebody forgets the
>>ia64_platform_is("sn2") check, bad things will happen.
>>
>>I'd like it a whole lot better if all these initialization-type things
>>could be hidden inside sn_setup() or some other machine vector.

The issue is that the initcalls are not executed at the same point in the boot 
-- there are seven levels of these and each level needs to be honoured. 
Placing them inside sn_setup() or some other machine vector is not the right 
thing to do (IMO -- there might be away to code around the levels that I'm 
unaware of).

> 
> 
> Me too ... these ia64_platform_is("sn2") are getting sprinkled in
> more and more places.
> 

I've been thinking about this and am wondering if the following solution might 
be more acceptable?

I'm also concerned about plugging in many ia64_platform_is checks into the code 
-- as Tony and Bjorn point out it seems that this approach is fraught with 
peril.  I'm also concerned about the possiblity of executing non-SGI code on one 
of my systems.

What if we added wrappers to the existing initcall functions to accept another 
argument?

Instead of subsys_initcall(fn) we would do

subarch_subsys_initcall (fn, arch) and this wrapper would do a platform check of 
the machine vector info?

ie)

subarch_subsys_initcall (init_foo, sn2)?


This seems a lot cleaner and would clean up other modular code as well.

I haven't completed my investigation yet -- the first patch that I submitted was 
in response to (what appeared to be) a minor issue reported by a colleague at 
another vendor and as Robin points out, is clearly only the start of the fix.

P.


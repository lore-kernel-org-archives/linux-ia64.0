From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 27 Sep 2009 05:18:41 +0000
Subject: RE: [git pull] ia64 changes
Message-Id: <alpine.LFD.2.01.0909262205520.3303@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Sat, 26 Sep 2009, Luck, Tony wrote:
> 
> Actually the ACCESS_ONCE() macro does end up with a "ld4.acq" here (because
> it defined with "volatile" in there, and the people that wrote the Itanium
> ABI said that compilers must generate .acq, .rel for volatile access.

Ahh, ok.

> However, when I ran the generated code with the .acq in here past one
> of the Itanium h/w architects, he said that it actually wasn't needed
> because the cmp/branch would also prevent accesses from inside the
> protected region from leaking out.

That seems to be purely an implementation (as opposed to architectural) 
detail.

But it looks like it is unlikely that we'll ever see an OoO ia64 
implementation, so I suspect that the implementations we have are all that 
matter.

> >   This allows 32768 different CPU's.
> 
> And 640K of memory should be enough for anyone :-)  SGI booted with 4096
> over a year ago ... so I'm not sure that 32768 cpus are really out of the
> question.

Well, the point is that we certainly don't support it _yet_. And if we 
ever do more than 32k CPU's, you'll have to recompile the kernel and have 
a 64-bit spinlock (the same way x86 does the 8/16-bit versions).

No sense in pessimizing the normal case if you can avoid it.

> >	unsigned short value = (*mem + 2) & ~1;
> >
> >	st2.rel.nta value,[mem]
> 
> This does suffer from the problem that you complained about for my
> spin_lock() function ... we will first get the cache line in shared
> mode and then have to upgrade to exclusive when we do the store ...

Yes. On the other hand, the common case for the spin_unlock should be that 
it's already dirty in the cache due to the preceding spin_lock(). So you'd 
have lost it from the cache only if there is contention, which should 
hopefully not be that common.

On x86, we avoid it by just doing a regular r-m-w operation (not atomic), 
which should be enough to get the "load with write intent" cache behavior. 
Apparently, on ia64 you can do the same with:

> We could perhaps make it less of an issue by using "ld.bias" to get
> the line exclusive to begin with.

Yes, sounds good.

			Linus

From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 15 May 2003 16:33:12 +0000
Subject: RE: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705839@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The patch looks mostly fine to me.  I'm not too fond of the __tpa()
> and __imva() macros, but that may be mainly a matter of preference.
> What I definitely don't like is that the casting seems rather confused
> and that the patch is adding __tpa() when we already have ia64_tpa().
> As an example of the casting issues: __imva() returns a long, but at
> times it's cast to "unsigned long" which doesn't make a lot of sense
> (for assignments, anyhow).  Moreover, we should stick to the Linux
> principle that kernel-space pointers have a type of "void *".

I can get rid of the __tpa() easily by using ia64_tpa() ... I'll
fix the type-casting fiasco while  making those changes.

Do you have some direction for the __imva() macro?  The acronym
stands for "Identity Mapped Virtual Address", and its purpose is
to provide the region 7 address for an object, so that the existing
code can continue to work without a whole lot of run-on changes.
If you just don't like the name, then it's easy to change to something
else.  If it's the typecast issue, then I can switch over to void *.
If it just makes your head hurt coping with schizophrenic dual
mapping that the kernel gets with this patch, then you'll just have
to take a couple of aspirin and look at the patch again in the
morning :-)

-Tony
 


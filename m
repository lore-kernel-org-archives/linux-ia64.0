From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Wed, 19 Nov 2003 20:15:23 +0000
Subject: RE: [PATCH] remove unimplemented syscalls noise
Message-Id: <marc-linux-ia64-106927294002395@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926030617023@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926030617023@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Well, in the case of unaligned faults, there is no other way for an
application to know that there were unaligned faults.  Whereas for
unsupported system calls, the kernel will return ENOSYS and thus the
application gets the required notification (so that it can take any
action it wants).  It does not need to depend on dmesg stuff to find
that information out.  

So, it does make sense to remove this printk (even though it is _debug_)
in this path.

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-
> owner@vger.kernel.org] On Behalf Of Matthew Wilcox
> Sent: Wednesday, November 19, 2003 11:54 AM
> To: davidm@hpl.hp.com
> Cc: Kyle McMartin; linux-ia64@vger.kernel.org
> Subject: Re: [PATCH] remove unimplemented syscalls noise
> 
> On Wed, Nov 19, 2003 at 11:44:46AM -0800, David Mosberger wrote:
> > What's wrong with dmesg -n4?  Those messages are marked KERN_DEBUG
for
> > a reason.  BTW: Red Hat does this by default, but Debian doesn't.
In
> > my opinion, Red Hat does the right thing here: by default, most
user's
> > don't care about such messages, but they're invaluable when tracking
> > down problems.
> 
> This is the same thing as printing the user unaligned exceptions.
> It's something no other architecture does, and for a reason, which has
> been explained to you before, but you don't want to fix it.  *sigh*.
> 
> --
> "It's not Hollywood.  War is real, war is primarily not about defeat
or
> victory, it is about death.  I've seen thousands and thousands of dead
> bodies.
> Do you think I want to have an academic debate on this subject?" --
Robert
> Fisk
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64"
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Matthew Wilcox <willy@debian.org>
Date: Mon, 12 May 2003 14:44:17 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] Increase size of user stack
Message-Id: <marc-linux-ia64-105590723705729@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 12, 2003 at 10:38:44AM -0400, Martin Hicks wrote:
> On Mon, May 05, 2003 at 11:25:33AM -0700, David Mosberger wrote:
> >   Martin> The current user stack size limit of 2GB is not big enough
> >   Martin> for large SMP or SSI clusters.  The following patch
> >   Martin> increases this size from 2GB to 512GB.  The new size is
> >   Martin> negotiable, but right now SGI has programs that require over
> >   Martin> 100GB of stack size on a 64 processor machine.  Setting the
> >   Martin> user stack size to 512GB seems like a reasonable thing to do
> >   Martin> for future growth.
> > 
> > Why not make it configurable via setrlimit() and be done with it once
> > and for all?
> 
> (sorry for taking so long to respond about this)
> 
> The user stack size is configurable through setrlimit().  The default 
> size of the user stack is 8MB and the max is ~0UL.  The problem is
> the addreses that are chosen for the stack (which grows down) and the
> register backing store (which grows up) are only 2GB apart.  My patch
> simply makes this space 512GB so that large stack are possible, without
> the stack smashing into the RBS.

Yes, but why not choose the addresses based on the current setting of
current->rlim[RLIMIT_STACK].rlim_max?  We could default that setting to
2GB (ie the same as what people are using now) and then set the RBS and
the user stack min(1TB, current->rlim[RLIMIT_STACK].rlim_max) apart.
Are there any disadvantages to doing this?

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk


From: Martin Hicks <mort@wildopensource.com>
Date: Mon, 12 May 2003 14:59:38 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] Increase size of user stack
Message-Id: <marc-linux-ia64-105590723705730@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, May 12, 2003 at 03:44:17PM +0100, Matthew Wilcox wrote:
> On Mon, May 12, 2003 at 10:38:44AM -0400, Martin Hicks wrote:
> > > 
> > (sorry for taking so long to respond about this)
> > 
> > The user stack size is configurable through setrlimit().  The default 
> > size of the user stack is 8MB and the max is ~0UL.  The problem is
> > the addreses that are chosen for the stack (which grows down) and the
> > register backing store (which grows up) are only 2GB apart.  My patch
> > simply makes this space 512GB so that large stack are possible, without
> > the stack smashing into the RBS.
> 
> Yes, but why not choose the addresses based on the current setting of
> current->rlim[RLIMIT_STACK].rlim_max?  We could default that setting to
> 2GB (ie the same as what people are using now) and then set the RBS and
> the user stack min(1TB, current->rlim[RLIMIT_STACK].rlim_max) apart.
> Are there any disadvantages to doing this?

Maybe I'm missing something, but what happens if a process is created
using the default 2GB between the RBS and the stack and sometime
later the process does a setrlimit to 100GB of stack.  How do the 
stack and RBS get moved around to make enough room between the two
start addresses?

mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com


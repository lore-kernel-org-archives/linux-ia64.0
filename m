From: Gary Hade <garyhade@us.ibm.com>
Date: Mon, 08 Apr 2002 23:27:35 +0000
Subject: Re: [Linux-ia64] C++ doesn't like asm/atomic.h
Message-Id: <marc-linux-ia64-105590701905419@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905396@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905396@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 09, 2002 at 08:59:50AM +1000, Keith Owens wrote:
> On Mon, 8 Apr 2002 12:33:40 -0700, 
> Gary Hade <garyhade@us.ibm.com> wrote:
> >I notice that the *_module(2) man pages which advocate the use of
> >#include <linux/module.h> are installed as part of the modutils
> >package.  Is is possibly "modutils" that should provide the header
> >file that avoids sucking in the possibly problematic kernel-only
> >code.
> 
> Old man pages (1996).  They date from the time that the kernel and
> glibc shared the kernel headers via a symlink.  Linus has changed his
> mind since then but the modutils man pages were never updated.
> 
> modutils provides include/module.h as part of the source package.  That
> file is not installated anywhere, nobody outside modutils has required
> it.  If you want to invoke the modutils syscalls yourself, take a copy
> of include/module.h from modutils into your source tree.  But don't be
> surprised if the interface changes under you.  modutils will know about
> any interface changes, other packages will have to cope with the
> version skew themselves.

FYI, I am not one of those outside of modutils that intends to use the 
modutils syscalls from either a C or C++ program.  The information in 
the flawed man pages appeared inconsistent with the assertion that code 
in asm/atomic.h is always off-limits to applications.  This prompted 
my questions which are now answered.

David/Ulrich/Keith, Thanks for the very informative discussion.

Gary


From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 16 Jan 2009 01:59:17 +0000
Subject: Re: linux-next: build problem with nfs tree (Was: Re:
Message-Id: <20090115175917.8e0ae536.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090115200315.EBE3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20090115093514.f3f6b8ff.akpm@linux-foundation.org>
	<20090116124949.7828a559.sfr@canb.auug.org.au>
In-Reply-To: <20090116124949.7828a559.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-next@vger.kernel.org, Prarit Bhargava <prarit@redhat.com>, David Howells <dhowells@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Sam Ravnborg <sam@ravnborg.org>, Kyle McMartin <kyle@mcmartin.ca>, Tony Luck <tony.luck@intel.com>, Trond Myklebust <trond.myklebust@fys.uio.no>

On Fri, 16 Jan 2009 12:49:49 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Andrew,
> 
> On Thu, 15 Jan 2009 09:35:14 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Thu, 15 Jan 2009 20:05:08 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > Applied after: linux-next.patch
> > > =
> > > Subject: [PATCH] remove duplicate EXPORT_SYMBOL()
> > > Impact: fix build error
> > > 
> > > In past, ia64_ksyms.c had EXPORT_SYMBOL(copy_page) in wrong place.
> > > 
> > > old code was
> > > 
> > > 	#include <asm/uaccess.h>
> > > 	EXPORT_SYMBOL(__copy_user);
> > > 	EXPORT_SYMBOL(__do_clear_user);
> > > 	EXPORT_SYMBOL(__strlen_user);
> > > 	EXPORT_SYMBOL(__strncpy_from_user);
> > > 	EXPORT_SYMBOL(__strnlen_user);
> > > 	EXPORT_SYMBOL(copy_page);
> > > 
> > > (but actually, copy_page is declared in asm/page.h)
> > > 
> > > And recently, commit bdc2619ab95d45d434c16d5c216bc6243761f6fb insert
> > > EXPORT_SYMBOL(copy_page) into correct place.
> > > 
> > > then, duplicate EXPORT_SYMBOL create following build error.
> > > 
> > > arch/ia64/kernel/ia64_ksyms.c:65: error: redefinition of '__kcrctab_copy_page'
> > > arch/ia64/kernel/ia64_ksyms.c:43: error: previous definition of '__kcrctab_copy_page' was here
> > > arch/ia64/kernel/ia64_ksyms.c:65: error: redefinition of '__kstrtab_copy_page'
> > > arch/ia64/kernel/ia64_ksyms.c:43: error: previous definition of '__kstrtab_copy_page' was here
> > > arch/ia64/kernel/ia64_ksyms.c:65: error: redefinition of '__ksymtab_copy_page'
> > > arch/ia64/kernel/ia64_ksyms.c:43: error: previous definition of '__ksymtab_copy_page' was here
> > 
> > Yes, this is a strange bug added by
> > 
> > commit 7aed50e09223e7623c7ab826efd53f097bed2f73
> > Author:     Prarit Bhargava <prarit@redhat.com>
> > AuthorDate: Sat Jan 10 02:25:44 2009 +0000
> > Commit:     David Howells <dhowells@redhat.com>
> > CommitDate: Sat Jan 10 02:25:44 2009 +0000
> > 
> >     CacheFiles: Add missing copy_page export for ia64
> > 
> > I don't see how it could have been tested :(
> > 
> > I also don't know which linux-next tree added that commit.  There's a
> > way of working this out but I forgot it.
> 
> In gitk you can search backwards for a merge commit containing "sfr" :-)

I do most of my gitting across a DSL connection.  It makes GUIs
painful.

> I have dropped the nfs tree from linux-next for today.

Just for this buglet?  That sounds a bit savage.

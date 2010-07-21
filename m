From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 21 Jul 2010 12:54:37 +0000
Subject: Re: ia64 hang/mca running gdb 'make check'
Message-Id: <20100721215140.86F3.A69D9226@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100721030629.GA9987@lackof.org> <alpine.DEB.1.00.1007202106420.12760@tigran.mtv.corp.google.com>
In-Reply-To: <alpine.DEB.1.00.1007202106420.12760@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hughd@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, dann frazier <dannf@dannf.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Ralf Baechle <ralf@linux-mips.org>

> On Tue, 20 Jul 2010, dann frazier wrote:
> > On Wed, Jul 21, 2010 at 10:51:36AM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 20 Jul 2010 11:35:12 -0600
> > > dann frazier <dannf@debian.org> wrote:
> > > 
> > > > Debian's ia64 autobuilders have been experiencing system crashes while
> > > > trying to run the gdb test suite:
> > > >   http://bugs.debian.org/cgi-bin/bugreport.cgi?bugX8574
> > > > 
> > > > I was able to reproduce this w/ the latest git tree, and bisected it
> > > > down to this commit, introduced in 2.6.32:
> > > > 
> > > >   commit 62eede62dafb4a6633eae7ffbeb34c60dba5e7b1
> > > >   Author: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> > > >   Date:   Mon Sep 21 17:03:34 2009 -0700
> > > > 
> > > >     mm: ZERO_PAGE without PTE_SPECIAL
> > > > 
> > > >     Reinstate anonymous use of ZERO_PAGE to all architectures, not just to
> > > >     those which __HAVE_ARCH_PTE_SPECIAL: as suggested by Nick Piggin.
> > > > 
> > > >     Contrary to how I'd imagined it, there's nothing ugly about this, just a
> > > >     zero_pfn test built into one or another block of vm_normal_page().
> > > > 
> > > >     But the MIPS ZERO_PAGE-of-many-colours case demands is_zero_pfn() and
> > > >     my_zero_pfn() inlines.  Reinstate its mremap move_pte() shuffling of
> > > >     ZERO_PAGEs we did from 2.6.17 to 2.6.19?  Not unless someone shouts for
> > > >     that: it would have to take vm_flags to weed out some cases.
> > > > 
> > > > fyi, I found this to not be reproducible on SLES11 SP1 (which is
> > > > 2.6.32-based). I compared the .configs and found that the relevant
> > > > difference is the PAGE_SIZE. It does not fail w/ 64KB pages, but
> > > > reliably fails w/ 16KB pages.
> > > > 
> > > 
> > > Sorry, I have no idea...
> > > Hmm, what is the address of empty_zero_page[] on your debian(16kb-page) ?
> > 
> > 
> > dannf@krebs:~$ grep empty_zero_page /boot/System.map-2.6.32-5-mckinley 
> > a0000001008784c0 d __ksymtab_empty_zero_page
> > a000000100882688 d __kcrctab_empty_zero_page
> > a000000100884ca4 r __kstrtab_empty_zero_page
> > a000000100974000 D empty_zero_page
> 
> Thanks a lot for reporting this, but I too have no idea yet.
> 
> It is likely that the bug is not to be found in that 62eede62, but
> rather in one of the preceding patches to mm/memory.c which 62eede62
> was extending to ia64 and other architectures without PTE_SPECIAL.
> 
> I wonder, from looking at that gdb testsuite log, is it plausible
> that all these hangs/crashes occurred when writing out a coredump?
> Is that something you could check for us? or rule out the possibility.
> 
> I was rather proud of the get_dump_page() simplification,
> but perhaps there's something nasty lurking in there.

Ug. I did tested some zero page thing at developing 62eede62 on ia64.
but unforunatelly, I've lost ia64 test environment by physical machine
crash. and I don't remember I did test which page size ;)

Umm... I also have no idea. sorry.




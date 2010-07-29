From: Hugh Dickins <hughd@google.com>
Date: Thu, 29 Jul 2010 03:50:18 +0000
Subject: Re: ia64 hang/mca running gdb 'make check'
Message-Id: <alpine.DEB.1.00.1007282031130.4207@tigran.mtv.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100720173512.GF26783@ldl.fc.hp.com> <20100721105136.9d4440de.kamezawa.hiroyu@jp.fujitsu.com> <20100721030629.GA9987@lackof.org> <alpine.DEB.1.00.1007202106420.12760@tigran.mtv.corp.google.com> <20100727071914.GB22945@lackof.org>
 <20100727180330.b6ecba7f.kamezawa.hiroyu@jp.fujitsu.com> <20100727144326.GC22945@lackof.org>
In-Reply-To: <20100727144326.GC22945@lackof.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dann frazier <dannf@debian.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Ralf Baechle <ralf@linux-mips.org>

On Tue, 27 Jul 2010, dann frazier wrote:
> On Tue, Jul 27, 2010 at 06:03:30PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 27 Jul 2010 01:19:15 -0600
> > dann frazier <dannf@debian.org> wrote:
> > > On Tue, Jul 20, 2010 at 09:19:50PM -0700, Hugh Dickins wrote:
> > > > On Tue, 20 Jul 2010, dann frazier wrote:
> > > > > On Wed, Jul 21, 2010 at 10:51:36AM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > > On Tue, 20 Jul 2010 11:35:12 -0600
> > > > > > dann frazier <dannf@debian.org> wrote:
> > > > > >=20
> > > > > > > Debian's ia64 autobuilders have been experiencing system cras=
hes while
> > > > > > > trying to run the gdb test suite:
> > > > > > >   http://bugs.debian.org/cgi-bin/bugreport.cgi?bugX8574
> > > > > > >=20
> > > > > > > I was able to reproduce this w/ the latest git tree, and bise=
cted it
> > > > > > > down to this commit, introduced in 2.6.32:
> > > > > > >=20
> > > > > > >   commit 62eede62dafb4a6633eae7ffbeb34c60dba5e7b1
> > > > > > >   Author: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> > > > > > >   Date:   Mon Sep 21 17:03:34 2009 -0700
> > > > > > >=20
> > > > > > >     mm: ZERO_PAGE without PTE_SPECIAL
> > > > > > >=20
> > > > > > >     Reinstate anonymous use of ZERO_PAGE to all architectures=
, not just to
> > > > > > >     those which __HAVE_ARCH_PTE_SPECIAL: as suggested by Nick=
 Piggin.
> > > > > > >=20
> > > > > > >     Contrary to how I'd imagined it, there's nothing ugly abo=
ut this, just a
> > > > > > >     zero_pfn test built into one or another block of vm_norma=
l_page().
> > > > > > >=20
> > > > > > >     But the MIPS ZERO_PAGE-of-many-colours case demands is_ze=
ro_pfn() and
> > > > > > >     my_zero_pfn() inlines.  Reinstate its mremap move_pte() s=
huffling of
> > > > > > >     ZERO_PAGEs we did from 2.6.17 to 2.6.19?  Not unless some=
one shouts for
> > > > > > >     that: it would have to take vm_flags to weed out some cas=
es.
> > > > > > >=20
> > > > > > > fyi, I found this to not be reproducible on SLES11 SP1 (which=
 is
> > > > > > > 2.6.32-based). I compared the .configs and found that the rel=
evant
> > > > > > > difference is the PAGE_SIZE. It does not fail w/ 64KB pages, =
but
> > > > > > > reliably fails w/ 16KB pages.
> > > > > > >=20
> > > > > >=20
> > > > > > Sorry, I have no idea...
> > > > > > Hmm, what is the address of empty_zero_page[] on your debian(16=
kb-page) ?
> > > > >=20
> > > > >=20
> > > > > dannf@krebs:~$ grep empty_zero_page /boot/System.map-2.6.32-5-mck=
inley=20
> > > > > a0000001008784c0 d __ksymtab_empty_zero_page
> > > > > a000000100882688 d __kcrctab_empty_zero_page
> > > > > a000000100884ca4 r __kstrtab_empty_zero_page
> > > > > a000000100974000 D empty_zero_page
> > > >=20
> > > > Thanks a lot for reporting this, but I too have no idea yet.
> > > >=20
> > > > It is likely that the bug is not to be found in that 62eede62, but
> > > > rather in one of the preceding patches to mm/memory.c which 62eede62
> > > > was extending to ia64 and other architectures without PTE_SPECIAL.
> > > >=20
> > > > I wonder, from looking at that gdb testsuite log, is it plausible
> > > > that all these hangs/crashes occurred when writing out a coredump?
> > > > Is that something you could check for us? or rule out the possibili=
ty.
> > >=20
> > > Yep, seems so. I've reduced it down to this test case:
> > >=20
> > > dannf@rx2600:~> cat > foo.c
> > > int leaf(void) {
> > >   return 0;
> > > }
> > >=20
> > > int main(void) {
> > >   leaf();
> > > }
> > > dannf@rx2600:~> gcc -g foo.c -o foo
> > > dannf@rx2600:~> gdb ./foo=20
> > > GNU gdb (GDB) SUSE (7.0-0.4.16)
> > > Copyright (C) 2009 Free Software Foundation, Inc.
> > > License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/g=
pl.html>
> > > This is free software: you are free to change and redistribute it.
> > > There is NO WARRANTY, to the extent permitted by law.  Type "show cop=
ying"
> > > and "show warranty" for details.
> > > This GDB was configured as "ia64-suse-linux".
> > > For bug reporting instructions, please see:
> > > <http://www.gnu.org/software/gdb/bugs/>...
> > > Reading symbols from /home/dannf/foo...done.
> > > (gdb) break leaf
> > > Breakpoint 1 at 0x40000000000005c1: file foo.c, line 2.
> > > (gdb) run
> > > Starting program: /home/dannf/foo=20
> > > Missing separate debuginfo for /lib/ld-linux-ia64.so.2
> > > Try: zypper install -C "debuginfo(build-id)=D5bfb8b5940e174d54b978ca5=
15dc0df76c7618c"
> > > Missing separate debuginfo for /lib/libc.so.6.1
> > > Try: zypper install -C "debuginfo(build-id)=CA78657bd9173653d95f8504a=
313d2b6db8cb1d6"
> > >=20
> > > Breakpoint 1, leaf () at foo.c:2
> > > 2	     return 0;
> > > (gdb) gcore /tmp/save
> > >=20
> > > [bang]
> > >=20
> >=20
> > Does this happen on 2.6.34 or 2.6.35-rc kernel ?
>=20
> I've been testing w/ a 2.6.35-rc4+, though it was originally reported
> on a 2.6.32.

Thanks a lot for narrowing down to that simple testcase, and
thanks a lot for checking it's just as bad on recent kernels.

I'm sorry to say that I'm still just as baffled.

Let's note that gdb's gcore is building up its own version of a
coredump, not going through the get_dump_page() code I was wondering
about.  If I read gcore correctly (possibly not!), it will be reading
selected areas from /proc/<pid>/mem i.e. using access_process_vm().

But why the (16kB but not 64kB!) zero page should make that freeze
or reboot, I have no idea.

What would I be doing if I had an Itanium?  I think I'd be trying to
narrow down exactly where it goes bad (tedious when the penalty is
a freeze or reboot).

As it is, I'm hoping that someone with an ia64 can investigate...

Hugh

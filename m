From: Luming Yu <luming.yu@gmail.com>
Date: Thu, 29 Jul 2010 07:38:06 +0000
Subject: Re: ia64 hang/mca running gdb 'make check'
Message-Id: <AANLkTi=5tYjnvg2UyLUD7eEFgn-qzkiAWzUyp4F+Yjzw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100720173512.GF26783@ldl.fc.hp.com>
	<20100721105136.9d4440de.kamezawa.hiroyu@jp.fujitsu.com>
	<20100721030629.GA9987@lackof.org>
	<alpine.DEB.1.00.1007202106420.12760@tigran.mtv.corp.google.com>
	<20100727071914.GB22945@lackof.org>
	<20100727180330.b6ecba7f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100727180330.b6ecba7f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: dann frazier <dannf@debian.org>, Hugh Dickins <hughd@google.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Ralf Baechle <ralf@linux-mips.org>

On Tue, Jul 27, 2010 at 5:03 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 27 Jul 2010 01:19:15 -0600
> dann frazier <dannf@debian.org> wrote:
>
>> On Tue, Jul 20, 2010 at 09:19:50PM -0700, Hugh Dickins wrote:
>> > On Tue, 20 Jul 2010, dann frazier wrote:
>> > > On Wed, Jul 21, 2010 at 10:51:36AM +0900, KAMEZAWA Hiroyuki wrote:
>> > > > On Tue, 20 Jul 2010 11:35:12 -0600
>> > > > dann frazier <dannf@debian.org> wrote:
>> > > >
>> > > > > Debian's ia64 autobuilders have been experiencing system crashes=
 while
>> > > > > trying to run the gdb test suite:
>> > > > > =C2=A0 http://bugs.debian.org/cgi-bin/bugreport.cgi?bugX8574
>> > > > >
>> > > > > I was able to reproduce this w/ the latest git tree, and bisecte=
d it
>> > > > > down to this commit, introduced in 2.6.32:
>> > > > >
>> > > > > =C2=A0 commit 62eede62dafb4a6633eae7ffbeb34c60dba5e7b1
>> > > > > =C2=A0 Author: Hugh Dickins <hugh.dickins@tiscali.co.uk>
>> > > > > =C2=A0 Date: =C2=A0 Mon Sep 21 17:03:34 2009 -0700
>> > > > >
>> > > > > =C2=A0 =C2=A0 mm: ZERO_PAGE without PTE_SPECIAL
>> > > > >
>> > > > > =C2=A0 =C2=A0 Reinstate anonymous use of ZERO_PAGE to all archit=
ectures, not just to
>> > > > > =C2=A0 =C2=A0 those which __HAVE_ARCH_PTE_SPECIAL: as suggested =
by Nick Piggin.
>> > > > >
>> > > > > =C2=A0 =C2=A0 Contrary to how I'd imagined it, there's nothing u=
gly about this, just a
>> > > > > =C2=A0 =C2=A0 zero_pfn test built into one or another block of v=
m_normal_page().
>> > > > >
>> > > > > =C2=A0 =C2=A0 But the MIPS ZERO_PAGE-of-many-colours case demand=
s is_zero_pfn() and
>> > > > > =C2=A0 =C2=A0 my_zero_pfn() inlines. =C2=A0Reinstate its mremap =
move_pte() shuffling of
>> > > > > =C2=A0 =C2=A0 ZERO_PAGEs we did from 2.6.17 to 2.6.19? =C2=A0Not=
 unless someone shouts for
>> > > > > =C2=A0 =C2=A0 that: it would have to take vm_flags to weed out s=
ome cases.
>> > > > >
>> > > > > fyi, I found this to not be reproducible on SLES11 SP1 (which is
>> > > > > 2.6.32-based). I compared the .configs and found that the releva=
nt
>> > > > > difference is the PAGE_SIZE. It does not fail w/ 64KB pages, but
>> > > > > reliably fails w/ 16KB pages.
>> > > > >
>> > > >
>> > > > Sorry, I have no idea...
>> > > > Hmm, what is the address of empty_zero_page[] on your debian(16kb-=
page) ?
>> > >
>> > >
>> > > dannf@krebs:~$ grep empty_zero_page /boot/System.map-2.6.32-5-mckinl=
ey
>> > > a0000001008784c0 d __ksymtab_empty_zero_page
>> > > a000000100882688 d __kcrctab_empty_zero_page
>> > > a000000100884ca4 r __kstrtab_empty_zero_page
>> > > a000000100974000 D empty_zero_page
>> >
>> > Thanks a lot for reporting this, but I too have no idea yet.
>> >
>> > It is likely that the bug is not to be found in that 62eede62, but
>> > rather in one of the preceding patches to mm/memory.c which 62eede62
>> > was extending to ia64 and other architectures without PTE_SPECIAL.
>> >
>> > I wonder, from looking at that gdb testsuite log, is it plausible
>> > that all these hangs/crashes occurred when writing out a coredump?
>> > Is that something you could check for us? or rule out the possibility.
>>
>> Yep, seems so. I've reduced it down to this test case:
>>
>> dannf@rx2600:~> cat > foo.c
>> int leaf(void) {
>> =C2=A0 return 0;
>> }
>>
>> int main(void) {
>> =C2=A0 leaf();
>> }
>> dannf@rx2600:~> gcc -g foo.c -o foo
>> dannf@rx2600:~> gdb ./foo
>> GNU gdb (GDB) SUSE (7.0-0.4.16)
>> Copyright (C) 2009 Free Software Foundation, Inc.
>> License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.=
html>
>> This is free software: you are free to change and redistribute it.
>> There is NO WARRANTY, to the extent permitted by law. =C2=A0Type "show c=
opying"
>> and "show warranty" for details.
>> This GDB was configured as "ia64-suse-linux".
>> For bug reporting instructions, please see:
>> <http://www.gnu.org/software/gdb/bugs/>...
>> Reading symbols from /home/dannf/foo...done.
>> (gdb) break leaf
>> Breakpoint 1 at 0x40000000000005c1: file foo.c, line 2.
>> (gdb) run
>> Starting program: /home/dannf/foo
>> Missing separate debuginfo for /lib/ld-linux-ia64.so.2
>> Try: zypper install -C "debuginfo(build-id)=D5bfb8b5940e174d54b978ca515d=
c0df76c7618c"
>> Missing separate debuginfo for /lib/libc.so.6.1
>> Try: zypper install -C "debuginfo(build-id)=CA78657bd9173653d95f8504a313=
d2b6db8cb1d6"
>>
>> Breakpoint 1, leaf () at foo.c:2
>> 2 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>> (gdb) gcore /tmp/save
>>
>> [bang]
>>
>
> Does this happen on 2.6.34 or 2.6.35-rc kernel ?


# gdb ./foo
GNU gdb (GDB) Red Hat Enterprise Linux (7.0.1-23.el5)
Copyright (C) 2009 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.htm=
l>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "ia64-redhat-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>...
Reading symbols from /root/foo...done.
(gdb) break leaf
Breakpoint 1 at 0x40000000000005a1: file foo.c, line 2.
(gdb) run
Starting program: /root/foo

Breakpoint 1, leaf () at foo.c:2
2       }
(gdb) gcore /tmp/save
Segmentation fault
# cat /proc/version
Linux version 2.6.35-rc3+ ...


Is the "segmentation fault" to be called reproduced?

>
> Thanks,
> -Kame
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
>

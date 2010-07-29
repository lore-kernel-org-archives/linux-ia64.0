From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 29 Jul 2010 08:44:47 +0000
Subject: Re: ia64 hang/mca running gdb 'make check'
Message-Id: <20100729174447.55d50801.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100720173512.GF26783@ldl.fc.hp.com>
	<20100721105136.9d4440de.kamezawa.hiroyu@jp.fujitsu.com>
	<20100721030629.GA9987@lackof.org>
	<alpine.DEB.1.00.1007202106420.12760@tigran.mtv.corp.google.com>
	<20100727071914.GB22945@lackof.org>
	<20100727180330.b6ecba7f.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=5tYjnvg2UyLUD7eEFgn-qzkiAWzUyp4F+Yjzw@mail.gmail.com>
	<20100729165801.f3a6dfe9.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=6L1NRYms69akf3uXyuge-0yQj=vrz9Nt=mQ_u@mail.gmail.com>
In-Reply-To: <AANLkTi=6L1NRYms69akf3uXyuge-0yQj=vrz9Nt=mQ_u@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Luming Yu <luming.yu@gmail.com>
Cc: dann frazier <dannf@debian.org>, Hugh Dickins <hughd@google.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Ralf Baechle <ralf@linux-mips.org>

On Thu, 29 Jul 2010 16:40:50 +0800
Luming Yu <luming.yu@gmail.com> wrote:

> On Thu, Jul 29, 2010 at 3:58 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 29 Jul 2010 15:38:06 +0800
> > Luming Yu <luming.yu@gmail.com> wrote:
> >
> >> On Tue, Jul 27, 2010 at 5:03 PM, KAMEZAWA Hiroyuki
> >
> >> # gdb ./foo
> >> GNU gdb (GDB) Red Hat Enterprise Linux (7.0.1-23.el5)
> >> Copyright (C) 2009 Free Software Foundation, Inc.
> >> License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
> >> This is free software: you are free to change and redistribute it.
> >> There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
> >> and "show warranty" for details.
> >> This GDB was configured as "ia64-redhat-linux-gnu".
> >> For bug reporting instructions, please see:
> >> <http://www.gnu.org/software/gdb/bugs/>...
> >> Reading symbols from /root/foo...done.
> >> (gdb) break leaf
> >> Breakpoint 1 at 0x40000000000005a1: file foo.c, line 2.
> >> (gdb) run
> >> Starting program: /root/foo
> >>
> >> Breakpoint 1, leaf () at foo.c:2
> >> 2       }
> >> (gdb) gcore /tmp/save
> >> Segmentation fault
> >> # cat /proc/version
> >> Linux version 2.6.35-rc3+ ...
> >>
> >>
> >
> > Hmm. What is EXEC_PAGESIZE installed in /usr/include/asm-generic/param.h ?
> 
> I use stock gdb shipped with RHEL 5.5.
> 
Hmm. RHEL5.5's EXEC_PAGESIZE is 64k, right ?
(And your kernel is 16k.)

> > And what happnes when modify it to 16k if it's 64k ?
> 
> Want me to repbuild a gdb with this modification?
> 
Ahhh, yes. It will be required...but plz when you have free time.
I don't think the difference can cause MCA or hang...

Thanks,
-Kame


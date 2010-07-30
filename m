From: Hugh Dickins <hughd@google.com>
Date: Fri, 30 Jul 2010 17:52:36 +0000
Subject: Re: ia64 hang/mca running gdb 'make check'
Message-Id: <alpine.DEB.1.00.1007301049230.21157@tigran.mtv.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100720173512.GF26783@ldl.fc.hp.com> <20100721105136.9d4440de.kamezawa.hiroyu@jp.fujitsu.com> <20100721030629.GA9987@lackof.org> <alpine.DEB.1.00.1007202106420.12760@tigran.mtv.corp.google.com> <20100727071914.GB22945@lackof.org>
 <20100727180330.b6ecba7f.kamezawa.hiroyu@jp.fujitsu.com> <20100727144326.GC22945@lackof.org> <alpine.DEB.1.00.1007282031130.4207@tigran.mtv.corp.google.com> <20100729192216.GF20265@lackof.org> <alpine.DEB.1.00.1007291853450.4466@tigran.mtv.corp.google.com>
 <20100730043423.GH20265@lackof.org>
In-Reply-To: <20100730043423.GH20265@lackof.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dann frazier <dannf@dannf.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Ralf Baechle <ralf@linux-mips.org>

On Thu, 29 Jul 2010, dann frazier wrote:
> 
> dannf@rx2600:~> gdb foo
> GNU gdb (GDB) SUSE (7.0-0.4.16)
> Copyright (C) 2009 Free Software Foundation, Inc.
> License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
> This is free software: you are free to change and redistribute it.
> There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
> and "show warranty" for details.
> This GDB was configured as "ia64-suse-linux".
> For bug reporting instructions, please see:
> <http://www.gnu.org/software/gdb/bugs/>...
> Reading symbols from /home/dannf/foo...done.
> (gdb) break leaf
> Breakpoint 1 at 0x4000000000000401: file foo.c, line 2.
> (gdb) run
> Starting program: /home/dannf/foo 
> 
> Breakpoint 1, leaf () at foo.c:2
> 2	     return 0;
> (gdb) gcore
> Saved corefile core.3952
> (gdb) 

Many thanks for pursuing this and reporting back, dann.
Patch to Linus follows in a few moments.

Hugh

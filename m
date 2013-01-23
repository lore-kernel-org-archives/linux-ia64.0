From: Borislav Petkov <bp@alien8.de>
Date: Wed, 23 Jan 2013 11:32:21 +0000
Subject: Re: [PATCH v4 00/13] Add gdb python scripts as kernel debugging helpers
Message-Id: <20130123113221.GA4256@pd.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1358787929.git.jan.kiszka@siemens.com>
In-Reply-To: <cover.1358787929.git.jan.kiszka@siemens.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Kiszka <jan.kiszka@siemens.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jason Wessel <jason.wessel@windriver.com>, kgdb-bugreport@lists.sourceforge.net, Andi Kleen <andi@firstfloor.org>, Tom Tromey <tromey@redhat.com>, Ben Widawsky <ben@bwidawsk.net>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Kay Sievers <kay@vrfy.org>, linux-ia64@vger.kernel.org, linux-kbuild@vger.kernel.org, Michal Marek <mmarek@suse.cz>, sparclinux@vger.kernel.org, Tony Luck <tony.luck@intel.com>

Ok, first of all, I gotta say, this is very cool stuff, thanks for doing
this. I'm playing with your tutorial and I'm having some trouble, see
below:

On Mon, Jan 21, 2013 at 06:06:07PM +0100, Jan Kiszka wrote:
>  o Let's examine the current task a bit:
>     (gdb) p ().pid

when I do that, it says:

(gdb) p ().pid
A syntax error in expression, near `).pid'

Here's what I do:

$ gdb --data-directory $(pwd)/scripts/gdb/ ./vmlinux
GNU gdb (GDB) 7.4.1-debian
Copyright (C) 2012 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>...
Reading symbols from /w/kernel/linux-2.6/vmlinux...done.
(gdb) target remote :1234
Remote debugging using :1234
[New Thread 2]
[Switching to Thread 2]
default_idle () at arch/x86/kernel/process.c:391
391             current_thread_info()->status |= TS_POLLING;
(gdb) p ().pid
A syntax error in expression, near `).pid'.
(gdb) show data-directory
GDB's data directory is "/w/kernel/linux-2.6/scripts/gdb/".
(gdb) lx-symbols
loading vmlinux
no modules found
(gdb) p ().pid
A syntax error in expression, near `).pid'.
(gdb)

So, I thought I should point it explicitly to the python scripts with
--data-directory but it still doesn't fly. And gdb is 7.4.1 so it should
be recent enough.

lx-dmesg works, for example:

(gdb) lx-dmesg
[     0.000000] Linux version 3.8.0-rc4+ (boris@pd) (gcc version 4.7.2 (Debian 4.7.2-5) ) #2 SMP PREEMPT Wed Jan 23 11:59:58 CET 2013
[     0.000000] Command line: vga=0 root=/dev/sda1 debug ignore_loglevel console=ttyS0,115200 console=tty0
[     0.000000] e820: BIOS-provided physical RAM map:
[     0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009f3ff] usable
[     0.000000] BIOS-e820: [mem 0x000000000009f400-0x000000000009ffff] reserved
[     0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[     0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007fffdfff] usable
...

So what am I missing?

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

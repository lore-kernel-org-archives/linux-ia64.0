From: Sachithanantham_Saravanan@emc.com
Date: Tue, 25 Jan 2005 15:16:21 +0000
Subject: LKCD on 2.6 IA64 Linux Kernel
Message-Id: <50C05B7AA7D6924FB5E384EF14BC647BCBBD63@inba1mx2.corp.emc.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, yakker@sgi.com, yakker@turbolinux.com, yakker@alacritech.com, matt@aparity.com
Cc: linux-kernel@vger.kernel.org

Hi all,

I tried using lkcd on a ia64 machine running on 2.6.5-7.111 SuSe Kernel for
debugging. I configured the swap device as the dump device and I created
panics,oops to generate dumps. The dump happens in /var/log/dump on a "lkcd
save" after a reboot. When I use lcrash to trace the task of the process
that caused the dump, I get some data misalignment errors as listed below.
And interestingly this happens only for the trace of the process that
generated the panic/oops. For all other processes in the dump trace is
giving me the proper output. Looks like the issue is specific to ia64 as I
did not encounter any such errors on my i386 machine on the same kernel. 
Pointers to any patches or what the problem is will be of help to me.

>> trace
lcrash(9187): unaligned access to 0x6000000001185ff7, ip=0x400000000004fa90
lcrash(9187): unaligned access to 0x6000000001185ff6, ip=0x400000000004fa90
lcrash(9187): unaligned access to 0x6000000001185ff5, ip=0x400000000004fa90
lcrash(9187): unaligned access to 0x6000000001185ff4, ip=0x400000000004fa90
Can't find trace for running task!
================================
STACK TRACE FOR TASK: 0xe0000001cc458000 (insmod)

================================
>>

Regards
Saravanan S

From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 06 Aug 2004 16:32:07 +0000
Subject: Re: ptrace problem on ia64 with kernel 2.4.26 (second)
Message-Id: <200408061032.07839.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408061155470.19996@lxmbe01.lrz.lrz-muenchen.de>
In-Reply-To: <Pine.LNX.4.58.0408061155470.19996@lxmbe01.lrz.lrz-muenchen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 06 August 2004 5:29 am, Mike Becher wrote:
> on our Linux IA64 cluster (17 nodes) we got the problem that tools like 
> strace, gdb, ddd, and other debugging tools, which depend on ptrace system 
> call, don't work after some days of uptime of a node.

Are you using current versions of strace and gdb?  There were some nasty
ptrace-related problems a year or so ago.  I don't remember all the details,
but I thought things were in fairly good shape now.

The fact that it works on a freshly-booted system, then starts failing
later does make it sound like a kernel issue, though.

> we have determined that Intel's debugger `idb' works on both
> kind of nodes. You can check the content of register r4, r5, and so on 
> while gdb and the other tools don't work anymore. It might be that `idb' 
> uses another way to get the register values than gdb on Linux-IA64.

Interesting.  Can you use strace to figure out the difference between
idb and gdb?

> Whether in messages files nor in /proc filesystem nor with dmesg I
> have found any info that can give me a hint what has changed. 

Was there a previous kernel version that did not exhibit this problem?
Does a current 2.6 kernel exhibit the problem?

I'll build a 2.4.26 kernel and leave it running over the weekend to
see whether I can reproduce it.

Bjorn

From: Mike Becher <Mike.Becher@lrz-muenchen.de>
Date: Mon, 09 Aug 2004 15:10:38 +0000
Subject: Re: ptrace problem on ia64 with kernel 2.4.26 (second)
Message-Id: <Pine.LNX.4.58.0408091628120.7810@lxmbe01.lrz.lrz-muenchen.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408061155470.19996@lxmbe01.lrz.lrz-muenchen.de>
In-Reply-To: <Pine.LNX.4.58.0408061155470.19996@lxmbe01.lrz.lrz-muenchen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 6 Aug 2004, Bjorn Helgaas wrote:

> On Friday 06 August 2004 5:29 am, Mike Becher wrote:
> > on our Linux IA64 cluster (17 nodes) we got the problem that tools like 
> > strace, gdb, ddd, and other debugging tools, which depend on ptrace system 
> > call, don't work after some days of uptime of a node.
> 
> Are you using current versions of strace and gdb?  There were some nasty
> ptrace-related problems a year or so ago.  I don't remember all the details,
> but I thought things were in fairly good shape now.
I have installed strace version 4.5.6. I got the RPM package from Fedora 
devel tree... same behavoir like with version 4.2.

> 
> The fact that it works on a freshly-booted system, then starts failing
> later does make it sound like a kernel issue, though.
I think alike.

> 
> > we have determined that Intel's debugger `idb' works on both
> > kind of nodes. You can check the content of register r4, r5, and so on 
> > while gdb and the other tools don't work anymore. It might be that `idb' 
> > uses another way to get the register values than gdb on Linux-IA64.
> 
> Interesting.  Can you use strace to figure out the difference between
> idb and gdb?
Hmm, there are some problems with that venture. First we can gather that 
kind of information only on working environment. OK, that is no problem. 
But if we doe something like:
  strace gdb -x gdb.input ./test01      (GDB version)
or
  strace idb -command idb.input ./test01 (Intel debugger version)
strace dies with SIGSEGV. Till that point we can provide information of 
output from strace on ia64. Additionally we provide information 
about output that will be genarated on ia32. Please have a look at archive 
`simple_c.tar.gz'. I don't post it to this list. You will get it directly 
from me.


> 
> > Whether in messages files nor in /proc filesystem nor with dmesg I
> > have found any info that can give me a hint what has changed. 
> 
> Was there a previous kernel version that did not exhibit this problem?
We don't see this problem on 2.4.21. There were no other kernel in use. 
But I will try it with a fresh RedHat AS 2.1 on one node and RedHat's 
2.4.18 kernel.

> Does a current 2.6 kernel exhibit the problem?
These systems are production systems. That why I cannot use 2.6, because 
there isn't a stable OpenAFS port available. Thats why we haven't any 
experience with that kernel. But I can try to install FC2 distribution to 
find out it works.

> 
> I'll build a 2.4.26 kernel and leave it running over the weekend to
> see whether I can reproduce it.
OK, I try to find out more with old RedHat AS 2.1 an Fedora Core 2 
configuration on ia64.

Mike

> 
> Bjorn
> 

-----------------------------------------------------------------------------
 Mike Becher                              Mike.Becher@lrz-muenchen.de
 Leibniz-Rechenzentrum der                http://www.lrz.de
 Bayerischen Akademie der Wissenschaften  phone: +49-89-289-28721      
 Gruppe Hochleistungssysteme              fax:   +49-89-280-9460
 Barer Strasse 21                    
 D-80333 Muenchen
 Germany                   
-----------------------------------------------------------------------------

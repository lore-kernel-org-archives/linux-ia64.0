From: Duraid Madina <Duraid@unsw.edu.au>
Date: Wed, 30 Jan 2002 05:48:36 +0000
Subject: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805950@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi guys,

	I've got a big (production) code that depends on a simple 'graph'
library in C++. To try it out on Itanium, I stripped it down and whipped up
a tiny 'benchmark' of the graph library. When I tried this on an Itanium
system here (2.4.9-SMP, gcc/g++ 2.96/3.0.3 and intel c++ 6.0) the code runs
for about 30 seconds, 20 of which is reported as 'system' time. The thing
is, this is (supposed to be) a CPU-bound job: on my home x86 system, it runs
in about 3 seconds, and with negligible system time.

	'top' and 'time' show the gobs of system time being used, but
'strace' picks up nothing out of the ordinary (0.014 seconds system time,
dominated by calls to brk() (this is expected).

	I'm hoping someone with a spare moment could try and reproduce this,
and perhaps let me know what's going on? Right now, I'm guessing libc
brokenness on ia64, but perhaps it's VM suckage? :\ Alas, on the box I have
access to, I can't profile the code because adding -pg when compiling leads
to a binary that segfaults at startup (ditto with the Intel compiler, so i'm
guessing the profile libraries are borked).

	You can grab the source (18kB) here:

	http://www.idesign.fl.net.au/why_systime/why_systime.tar.gz

	just 'make' (be sure 'gcc' and 'g++' point to a recent enough
version of gcc/g++ - preferably 3.0 or later) and then run 'a.out'.

	Lost,

	Duraid



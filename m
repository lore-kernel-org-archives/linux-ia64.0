From: Weihaw CHUANG <wchuang@cs.ucsd.edu>
Date: Wed, 18 Apr 2001 04:59:13 +0000
Subject: [Linux-ia64] ia64 emulation
Message-Id: <marc-linux-ia64-105590693005418@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi 
I new to this mailing list, so I hope I have the right forum.  Otherwise I
apologize, and please ignore this email.

I am trying to build ia64 out-of-order simulator using U Wisconsin's 
Simple Scalar simulator.  I need a functional simulator/emulator for ia64.  

My first question is has anyone developed an ia64 open source simulator
capable of at least dealing with basic system calls.  A cursory search
seems to indicate no =(.  Since IA64 has a lot of state to emulate,
building a functional simualator from scratch appears to be a bad idea.

Another option might be try single stepping on an Itanium box, and
controlling a context directly.  This seems a little bit more feasible but
still pretty daunting.  

My second question is what is the name of the linux context switch module
and procedure in the linux kernel distribution.  My guess is that the
author of this module is actually on this mailing list.  

Also it appears that modifying PSR.ss (single step) is priviledged.
So my guess is that I'll have to modify a linux kernel to allow the
SimpleScalar simulator to run with kernel (lv 0) priviledges perhaps by
creating a system call that doesn't rfi, and br.ret instead?

Any thoughts would be greatly appreciated!!

-Wei    



From: Weihaw Chuang <weihaw@yahoo.com>
Date: Mon, 24 Sep 2001 01:43:18 +0000
Subject: [Linux-ia64] differentiating single-step vs taken-branch trap
Message-Id: <marc-linux-ia64-105590698805241@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi everyone,
I've got two questions, but only the first is really
important.  
1. I'm using the ptrace kernel interface to trace a
child process via single-step or taken-branch traps
(through David Mosberger's utrace tool).  Is there a
way I can use ptrace to allow me to single-step, and
in addition observe occurances of taken-branches?  

It seems that its possible to set the PSR.SS and
PSR.TB concurrently, but not a way of differentiating
the returned trap signal.  All we know upon returning
from wait is that a trap occured.

Although it seems redundant, as far as I know there is
a subtle difference between taken-branch traps and
single-step traps.  Taken-branch traps return back an
IIP value of the branch target, before committing the
the results of the target instruction.  Single-step
traps assign IIP of the committed instruction.  The
difference is important if I want to look ahead to get
register state before a memory operation commits any
registers writes.   

2. Is there still a ia64 linux kernel mailing list? 
And is it archived somewhere?

Many thanks,
-Wei

==************************************************************

Weihaw Chuang
wchuang@cs.ucsd.edu

************************************************************

__________________________________________________
Do You Yahoo!?
Get email alerts & NEW webcam video instant messaging with Yahoo! Messenger. http://im.yahoo.com


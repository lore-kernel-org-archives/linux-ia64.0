From: n0ano@indstorage.com
Date: Mon, 24 Sep 2001 14:46:51 +0000
Subject: Re: [Linux-ia64] differentiating single-step vs taken-branch trap
Message-Id: <marc-linux-ia64-105590698805242@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805241@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805241@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Weihaw-

1)  I don't believe that `ptrace' distinguishes between
these two events.  As far as `ptrace' is concerned you've
executed a single instruction, taken branch or not.  It
shouldn't be too hard to infer whether a branch was taken
or not.  If the current bundle is not 1 greater than the
last bundle then a branch was taken, otherwise a branch
was most probably not taken.  This will miss a branch to
the next instruction (seems pretty silly code) or a branch
around the one or two instructions that could follow inside
the same bundle holding the branch.  The two exception
cases are pretty rare and you could do some instruction
dis-assembly to catch them if you really care.

2)  Go to `www.linuxia64.com' and follow the link to
`kernel developers list'.  This will lead to the archive for
the mailing list.  (You posted this message to the IA64 mailing
list so obviously the list still exists :-)

On Sun, Sep 23, 2001 at 06:43:18PM -0700, Weihaw Chuang wrote:
> Hi everyone,
> I've got two questions, but only the first is really
> important.  
> 1. I'm using the ptrace kernel interface to trace a
> child process via single-step or taken-branch traps
> (through David Mosberger's utrace tool).  Is there a
> way I can use ptrace to allow me to single-step, and
> in addition observe occurances of taken-branches?  
> 
> It seems that its possible to set the PSR.SS and
> PSR.TB concurrently, but not a way of differentiating
> the returned trap signal.  All we know upon returning
> from wait is that a trap occured.
> 
> Although it seems redundant, as far as I know there is
> a subtle difference between taken-branch traps and
> single-step traps.  Taken-branch traps return back an
> IIP value of the branch target, before committing the
> the results of the target instruction.  Single-step
> traps assign IIP of the committed instruction.  The
> difference is important if I want to look ahead to get
> register state before a memory operation commits any
> registers writes.   
> 
> 2. Is there still a ia64 linux kernel mailing list? 
> And is it archived somewhere?
> 
> Many thanks,
> -Wei
> 
> ==> ************************************************************
> 
> Weihaw Chuang
> wchuang@cs.ucsd.edu
> 
> ************************************************************
> 
> __________________________________________________
> Do You Yahoo!?
> Get email alerts & NEW webcam video instant messaging with Yahoo! Messenger. http://im.yahoo.com
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117


From: Raj Patil <rpatil0296@yahoo.com>
Date: Fri, 30 May 2003 16:21:54 +0000
Subject: Re: [Linux-ia64] sys_clone() related info/help/pointer needed
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0-249732772-1054311714=:64176"
Message-Id: <marc-linux-ia64-105590723706087@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705986@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705986@msgid-missing>
To: linux-ia64@vger.kernel.org

--0-249732772-1054311714=:64176
Content-Type: text/plain; charset=us-ascii

Thanks for your comments/info David.
(was out for few days...)
 
One thing I am not clear is why should it be different when sys_clone()
is called as part of the regulare syscall and from a module as another
syscall. Both of them are going through the same path; sys_clone(),
do_fork(), copy_thread(). Am I missing something vey obvious to see the
difference?
 
BTW: I bought "ia-64 linux kernel design and implementation" book.
         It is very well wriiten. 
         I am going through the 3rd chapter on threads for clone2()/
        switch_stack/copy_thread etc. It will take some time to digest 
         the info....
 
Thanks,
Raj

David Mosberger <davidm@napali.hpl.hp.com> wrote:

>>>>> On Thu, 22 May 2003 13:36:19 -0700 (PDT), Raj Patil said:

Raj> The progam basically adds an entry to syscall table, and when
Raj> this new syscall is called, it simply calls sys_clone() with
Raj> same arguments. (like making a duplicate sys_clone call)
Raj> static long my_call(unsigned long flags, unsigned long sz) {
Raj> rc=sys_clone(flags, sz); /* sys_clone is exported */ ...... }
Raj> Everything seems to work excpet that the child process created
Raj> is not getting executed.

clone() (or, more correctly: clone2()) is special: it needs both a
pt_regs and a switch_stack structure at the top of the stack (see
comments in arch/ia64/kernel/process.c for copy_thread()). Your
test-case doesn't work because it probably isn't creating the
switch_stack structure at all.

--david



---------------------------------
Do you Yahoo!?
Free online calendar with sync to Outlook(TM).
--0-249732772-1054311714=:64176
Content-Type: text/html; charset=us-ascii

<DIV>
<DIV>Thanks for your comments/info David.</DIV>
<DIV>(was out for few days...)</DIV>
<DIV>&nbsp;</DIV>
<DIV>One thing I am not clear is why should it be different when sys_clone()</DIV>
<DIV>is called as part of the regulare syscall and from a module as another</DIV>
<DIV>syscall. Both of them are going through the same path; sys_clone(),</DIV>
<DIV>do_fork(), copy_thread(). Am I missing something vey obvious to see the</DIV>
<DIV>difference?</DIV>
<DIV>&nbsp;</DIV>
<DIV>BTW: I bought "ia-64 linux kernel design and implementation" book.</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; It is very well wriiten. </DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; I am going through the 3rd chapter on threads for clone2()/</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; switch_stack/copy_thread etc. It will take some time to digest </DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; the info....</DIV>
<DIV>&nbsp;</DIV>
<DIV>Thanks,</DIV>
<DIV>Raj</DIV>
<DIV><BR><B><I>David Mosberger &lt;davidm@napali.hpl.hp.com&gt;</I></B> wrote:</DIV>
<BLOCKQUOTE style="PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #1010ff 2px solid">
<P>&gt;&gt;&gt;&gt;&gt; On Thu, 22 May 2003 13:36:19 -0700 (PDT), Raj Patil <RPATIL0296@YAHOO.COM>said:<BR><BR>Raj&gt; The progam basically adds an entry to syscall table, and when<BR>Raj&gt; this new syscall is called, it simply calls sys_clone() with<BR>Raj&gt; same arguments. (like making a duplicate sys_clone call)<BR>Raj&gt; static long my_call(unsigned long flags, unsigned long sz) {<BR>Raj&gt; rc=sys_clone(flags, sz); /* sys_clone is exported */ ...... }<BR>Raj&gt; Everything seems to work excpet that the child process created<BR>Raj&gt; is not getting executed.<BR><BR>clone() (or, more correctly: clone2()) is special: it needs both a<BR>pt_regs and a switch_stack structure at the top of the stack (see<BR>comments in arch/ia64/kernel/process.c for copy_thread()). Your<BR>test-case doesn't work because it probably isn't creating the<BR>switch_stack structure at all.<BR><BR>--david</P></BLOCKQUOTE></DIV><p><hr SIZE=1>
Do you Yahoo!?<br>
Free <a href="http://us.rd.yahoo.com/mail_us/tag/*http://calendar.yahoo.com">online calendar</a> with sync to Outlook(TM).
--0-249732772-1054311714=:64176--


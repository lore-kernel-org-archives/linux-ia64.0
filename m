From: Raj Patil <rpatil0296@yahoo.com>
Date: Thu, 22 May 2003 20:36:19 +0000
Subject: [Linux-ia64] sys_clone() related info/help/pointer needed
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0-704779453-1053635779=:41649"
Message-Id: <marc-linux-ia64-105590723705986@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--0-704779453-1053635779=:41649
Content-Type: text/plain; charset=us-ascii

Hello,
 
I am trying to port (time permitting) a small ia32 package to ia64.
One of the thing it does are not supposed to be done that way.
Like it adds a new syscall entry to the syscall table. But, I am doing
this just to see how this tiny stuff from ia32 works on ia64 without 
getting into dynamically adding the new sys call discussion.
 
The progam basically adds an entry to syscall table, and when this
new syscall is called, it simply calls sys_clone() with same arguments.
(like making a duplicate sys_clone call)
static long my_call(unsigned long flags, unsigned long sz)
{
      rc=sys_clone(flags, sz); /* sys_clone is exported */
       ......
}
Everything seems to work excpet that the child process created is not
getting executed.  I can see that the  return value from the sys_clone is
the pid of the child process and the task struct for the child getting set 
etc. But, the child process created does not get executed. I don't see
 any error messages in dmesg output either. So, I am not sure what 
is going wrong and what exactly to look. (Yes, I am  relatively new to
 Linux.) Any suggestions or pointers to try will be greatly appreciated. (Hooking up the gdb over serial port would be a stretch as the machine
is shared by other folks and I am trying this on the side. )
The sys_clone() is an assembly code which calls do_fork after setting
the regs and performing do_save_switch_stack etc.I don't see any
thing obvious there or in do_fork code.
 
Thanks for any suggestions/pointers/info to try.
 
Regards,
Raj
 


---------------------------------
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo.
--0-704779453-1053635779=:41649
Content-Type: text/html; charset=us-ascii

<DIV>Hello,</DIV>
<DIV>&nbsp;</DIV>
<DIV>I am trying to port (time permitting)&nbsp;a small ia32 package to ia64.</DIV>
<DIV>One&nbsp;of the thing it does are not supposed to be done that way.</DIV>
<DIV>Like it adds a new syscall entry to the syscall table. But, I am doing</DIV>
<DIV>this just to see how this tiny&nbsp;stuff from ia32 works on ia64 without </DIV>
<DIV>getting into dynamically adding the new sys call discussion.</DIV>
<DIV>&nbsp;</DIV>
<DIV>The progam basically adds an entry to syscall table, and when this</DIV>
<DIV>new syscall is called, it simply calls sys_clone() with same arguments.</DIV>
<DIV>(like making a duplicate sys_clone call)</DIV>
<DIV>static long my_call(unsigned long flags, unsigned long sz)</DIV>
<DIV>{</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rc=sys_clone(flags, sz); /* sys_clone is exported */</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ......</DIV>
<DIV>}</DIV>
<DIV>Everything seems to work excpet that the child process created is not</DIV>
<DIV>getting executed.&nbsp; I can see that the &nbsp;return value from the sys_clone is</DIV>
<DIV>the pid of the child process and the task struct for the child getting set </DIV>
<DIV>etc. But, the child process created does not get executed. I don't see</DIV>
<DIV>&nbsp;any error messages in dmesg output either. So, I am not sure what </DIV>
<DIV>is going wrong and what exactly to look. (Yes, I am&nbsp; relatively new to</DIV>
<DIV>&nbsp;Linux.) Any suggestions or pointers to try will be greatly appreciated. (Hooking up the gdb over serial port would be a stretch as the machine</DIV>
<DIV>is shared by other folks and I am trying this on the side. )</DIV>
<DIV>The sys_clone() is an assembly code which calls do_fork after setting</DIV>
<DIV>the regs and performing do_save_switch_stack etc.I don't see any</DIV>
<DIV>thing obvious there or in do_fork code.</DIV>
<DIV>&nbsp;</DIV>
<DIV>Thanks for any suggestions/pointers/info to try.</DIV>
<DIV>&nbsp;</DIV>
<DIV>Regards,</DIV>
<DIV>Raj</DIV>
<DIV>&nbsp;</DIV><p><hr SIZE=1>
Do you Yahoo!?<br>
<a href="http://us.rd.yahoo.com/search/mailsig/*http://search.yahoo.com">The New Yahoo! Search</a> - Faster. Easier. Bingo.
--0-704779453-1053635779=:41649--


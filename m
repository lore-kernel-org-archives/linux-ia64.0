From: Raj Patil <rpatil0296@yahoo.com>
Date: Fri, 14 Mar 2003 15:08:51 +0000
Subject: [Linux-ia64] How to set/reset gp pointer : info needed
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0-328902887-1047654531=:30698"
Message-Id: <marc-linux-ia64-105590709806096@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--0-328902887-1047654531=:30698
Content-Type: text/plain; charset=us-ascii


Hello,

I am not sure whether this is the right group for me to ask this or get the

kind of information I am looking for. I apologize if this is not the

right group. I am relatively new to Linux/ia64 and this question is related

to ia64. Hence, decided to post it here 

I am looking for some info on how to set/unset the gp pointer, locations/cases

where I need to set and any other issues I need to worry. Any pointers to

some documentation or sample code or notes will be really appreciated.

Reason: I am just trying to port an utility to ia64 based Linux platform from 

x86 platform. It adds an entry to syscall table to point to a function in 

a module. It is like adding a new temp syscall for a small duration. 

By looking at some documentation, I realized that I need to set 

the gp pointer correctly before calling the function (not sure exactly wehre

and how). So, I am looking for some docs/notes which clarify my doubts like

-what in general needs to be done to set/reset gp (where?).

-Does this need to be done if one is adding an entry to ia32 syscall 

table too? 

-If this new function in the module calls other kernel functions in between,

should it worry about gp pointer before calling the kernel functions etc.

I have access to RH Advanced Server 2.1 running on an HP Itanium-2 box.

Thank you very much for any pointers/info.

Regards,

Raj



---------------------------------
Do you Yahoo!?
Yahoo! Web Hosting - establish your business online
--0-328902887-1047654531=:30698
Content-Type: text/html; charset=us-ascii

<FONT size=2>
<P>Hello,</P>
<P>I am not sure whether this is the right group for me to ask this or get the</P>
<P>kind of information I am looking for. I apologize if this is not the</P>
<P>right group. I am relatively new to Linux/ia64 and this question is related</P>
<P>to ia64. Hence, decided to post it here </P>
<P>I am looking for some info on how to set/unset the gp pointer, locations/cases</P>
<P>where I need to set and any other issues I need to worry. Any pointers to</P>
<P>some documentation or sample code or notes will be really appreciated.</P>
<P>Reason: I am just trying to port an utility to ia64 based Linux platform from </P>
<P>x86 platform. It adds an entry to syscall table to point to a function in </P>
<P>a module. It is like adding a new temp syscall for a small duration. </P>
<P>By looking at some documentation, I realized that I need to set </P>
<P>the gp pointer correctly before calling the function (not sure exactly wehre</P>
<P>and how). So, I am looking for some docs/notes which clarify my doubts like</P>
<P>-what in general needs to be done to set/reset gp (where?).</P>
<P>-Does this need to be done if one is adding an entry to ia32 syscall </P>
<P>table too? </P>
<P>-If this new function in the module calls other kernel functions in between,</P>
<P>should it worry about gp pointer before calling the kernel functions etc.</P>
<P>I have access to RH Advanced Server 2.1 running on an HP Itanium-2 box.</P>
<P>Thank you very much for any pointers/info.</P>
<P>Regards,</P>
<P>Raj</P></FONT><p><br><hr size=1>Do you Yahoo!?<br>
<a href="http://rd.yahoo.com/webhosting/mail_tagline/evt=7748/*http://webhosting.yahoo.com/ps/wh3/prod/">Yahoo! Web Hosting</a> - establish your business online
--0-328902887-1047654531=:30698--


From: Raj Patil <rpatil0296@yahoo.com>
Date: Fri, 14 Mar 2003 17:56:12 +0000
Subject: Re: [Linux-ia64] How to set/reset gp pointer : info needed
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0-2073097715-1047664572=:67986"
Message-Id: <marc-linux-ia64-105590709806103@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806096@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806096@msgid-missing>
To: linux-ia64@vger.kernel.org

--0-2073097715-1047664572=:67986
Content-Type: text/plain; charset=us-ascii


I will check the source of this tool/module...... 
But, curious: You mean, one can not legally add a new syscall or hook? 
This process as such does not use/modify the kernel source.... 
Regards, 
Raj. 
 David Mosberger <davidm@napali.hpl.hp.com> wrote: >>>>> On Fri, 14 Mar 2003 07:08:51 -0800 (PST), Raj Patil said:

Raj> Reason: I am just trying to port an utility to ia64 based Linux
Raj> platform from x86 platform. It adds an entry to syscall table
Raj> to point to a function in a module. It is like adding a new
Raj> temp syscall for a small duration.

Is the module open-source? If not, you run the risk of violating the
kernel's GPL license (binary-only modules are OK but only as long as
they use "standard" kernel interfaces; planting a syscall-hook goes
beyond that).

--david


---------------------------------
Do you Yahoo!?
Yahoo! Web Hosting - establish your business online
--0-2073097715-1047664572=:67986
Content-Type: text/html; charset=us-ascii

<P>I will check the source of this tool/module...... 
<P>But, curious: You mean, one can not legally add a new syscall or hook? 
<P>This process as&nbsp;such does not use/modify the kernel source.... 
<P>Regards, 
<P>Raj. 
<P>&nbsp;<B><I>David Mosberger &lt;davidm@napali.hpl.hp.com&gt;</I></B> wrote: 
<BLOCKQUOTE style="PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #1010ff 2px solid">&gt;&gt;&gt;&gt;&gt; On Fri, 14 Mar 2003 07:08:51 -0800 (PST), Raj Patil <RPATIL0296@YAHOO.COM>said:<BR><BR>Raj&gt; Reason: I am just trying to port an utility to ia64 based Linux<BR>Raj&gt; platform from x86 platform. It adds an entry to syscall table<BR>Raj&gt; to point to a function in a module. It is like adding a new<BR>Raj&gt; temp syscall for a small duration.<BR><BR>Is the module open-source? If not, you run the risk of violating the<BR>kernel's GPL license (binary-only modules are OK but only as long as<BR>they use "standard" kernel interfaces; planting a syscall-hook goes<BR>beyond that).<BR><BR>--david</BLOCKQUOTE><p><br><hr size=1>Do you Yahoo!?<br>
<a href="http://rd.yahoo.com/webhosting/mail_tagline/evt=7748/*http://webhosting.yahoo.com/ps/wh3/prod/">Yahoo! Web Hosting</a> - establish your business online
--0-2073097715-1047664572=:67986--


From: Rich Altmaier <richa@sgi.com>
Date: Wed, 19 Nov 2003 21:13:48 +0000
Subject: Re: [PATCH] remove unimplemented syscalls noise
Message-Id: <marc-linux-ia64-106927695508036@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926030617023@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926030617023@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't have an answer here, but some perspective to offer.
Over the years we have found that customers will react to
any message in the SYSLOG file.  That is, you get the least
grief by having messages appear there when you want the
customer/administrator to take an action.  If they are not
to take an action, then don't show the message.

For debugging, we have used schemes which don't raise the
debug data to the "normal system administration" procedures.
Such as a private kernel logging buffer, dumped together with
a kernel core dump, or viewable by a kernel debugger if you
know where to look, etc.  But not part of normal documented
system admin procedures.

Of course for debugging we like good data...
FYI, Rich



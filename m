From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 15 Jun 2000 14:44:02 +0000
Subject: Re: [Linux-ia64] signal interface: SIGINFO and sa_sigaction
Message-Id: <marc-linux-ia64-105590678205140@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205139@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205139@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, I see what you mean.  It looks like the glibc header file doesn't
define sa_sigaction as a (properly typed) synonym of sa_handler.  Jes,
can you fix this?  It looks to me that the IA-64 "struct sigaction"
should be defined like in sysdeps/unix/sysv/linux/bits/sigaction.h.

Note that from the kernel perspective, there is no difference between
sa_handler and sa_sigaction.  So as a quick workaround, you can simply
use sa_handler with the appropriate type cast.

	--david

>>>>> On Wed, 14 Jun 2000 17:04:41 +0100, SCHAN@uk.ibm.com said:

  Sunny> Hello,

  Sunny> I am porting some applications over from Linux x86 to IA64,
  Sunny> and run into problem with the signals - It seems to me that
  Sunny> the IA64 kernel hasn't implement the sa_sigaction interface
  Sunny> for singal handlers - which, according to the man page,
  Sunny> should be implemented for Kernel 2.1.86. Just wonder whether
  Sunny> the IA64 kernel will be done up to support it?



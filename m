From: stefan <stefan@lkcc.org>
Date: Thu, 20 Sep 2001 17:34:00 +0000
Subject: [Linux-ia64] getcontext() correctly implemented ?
Message-Id: <marc-linux-ia64-105590698805230@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello list,

in order to save the full register set of the ia64 I want to use
getcontext(&ctx) instead of setjmp(jmpbuf) and check the registers in
ctx.uc_mcontext for references in a garbage collected system.

My question is: Is getcontext() correctly implemented in glibc(). Which
version do I need and can I use it for the described purpose at all ?

Thanks in advance,
	stefan@lkcc.org



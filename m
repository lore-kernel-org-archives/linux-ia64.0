From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Fri, 21 Jul 2006 17:09:39 +0000
Subject: bogus gas error messages
Message-Id: <ed5aea430607211009l37cad6afj39cf70865a81d3ef@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trying to compile libunwind, I'm now getting these error messages:

  ia64-test-readonly-asm.S:37: Error: Operand 2 to .spillreg must be a
writable register

These are bogus errors in my opinion and should be removed.  For
example, we already commonly use "saves" to r0 to terminate the
call-chain.  I'm seeing this with gas v2.17, but it may have been
around for longer.

Thanks,

  --david
-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/

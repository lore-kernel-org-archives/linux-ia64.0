From: Jim Wilson <wilson@cygnus.com>
Date: Sat, 24 Mar 2001 01:37:19 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005350@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>To me, the EH model is better thought of not as a set of regions, but as 
>a set of discrete points in the code where an exception can be raised. 

Compactness of the representation is a concern.  Using tables to describe
ranges of address is relatively compact.  I know that the new C++ ABI
uses a possibly different representation that is reasonably compact, but I
don't know how it achieves it.

In C++, exceptions can only be raised by a call to throw.  Thus they can
only occur at a few discrete points.  However, in other languages, Java and
Ada in particular, exceptions can be raised in many other cases.  I think
the Java case is simpler, they only specify a few additional cases like
divide by zero.  However, I believe Ada allows any instruction to generate
exceptions.  This is called asynchonous exceptions in the gcc source code.
We don't handle asynchronous exceptions correctly in gcc, but it would be
good if we didn't arbitrarily exclude future support for them.  If every
instruction can throw an exception, then does it still make sense to keep
track of them as discrete points?  I believe the gcc Ada front end already has
its own exception handling code which is different from the gcc middle end
code used for C/C++/Java/etc, so perhaps we don't care whether this EH
scheme ever works for Ada.

Disclaimer: I am not a C++, Java, or Ada expert.

Perhaps I should just go off and study the new EH scheme so I can answer my
own questions.

Jim


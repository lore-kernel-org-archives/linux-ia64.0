From: "DE-DINECHIN,CHRISTOPHE (HP-Cupertino,ex1)" <christophe_de-dinechin@hp.com>
Date: Mon, 26 Mar 2001 22:06:40 +0000
Subject: RE: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005354@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jim,


Note that the current exception handling model uses two levels of table:

- A first level describes an "unwind region", and it indeed describes ranges
as you would expect.

- A second level is language-specific. For C++, since C++ exceptions occur
only at a call point (including a call to the "throw" library routine), it
is a table of instruction addresses. This allows us, among others, to detect
if an exception is thrown from an unexpected place. And for C++, it is
unclear that it really wastes space compared to a range-based mechanism.

With respect to exceptions in other languages, the most complex case is
probably that of Ada. Although the last time I worked on an Ada compiler was
almost 10 years ago, I know that our current C++ scheme would be difficult
to implement in Ada. So the language-specific part for Ada would have to be
very different (essentially, listing ranges of code as you suggested.) 


Regards
Christophe

-----Original Message-----
From: linux-ia64-admin@linuxia64.org
[mailto:linux-ia64-admin@linuxia64.org]On Behalf Of Jim Wilson
Sent: Friday, March 23, 2001 5:37 PM
To: Cary Coutant
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn 


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
track of them as discrete points?  I believe the gcc Ada front end already
has
its own exception handling code which is different from the gcc middle end
code used for C/C++/Java/etc, so perhaps we don't care whether this EH
scheme ever works for Ada.

Disclaimer: I am not a C++, Java, or Ada expert.

Perhaps I should just go off and study the new EH scheme so I can answer my
own questions.

Jim

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


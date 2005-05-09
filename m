From: Gerald Pfeifer <gp@suse.de>
Date: Mon, 09 May 2005 20:37:56 +0000
Subject: Re: Divide by zero works on ia64!!!
Message-Id: <Pine.LNX.4.61.0505092229440.16363@lifschitz.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1115652187.28663.4.camel@lyra.fc.hp.com>
In-Reply-To: <1115652187.28663.4.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 9 May 2005, Khalid Aziz wrote:
> Following program causes floating point exception on x86 (compiled with
> gcc 3.3.5 (Debian 1:3.3.5-8)) as expected, but runs fine on ia64 when
> compiled with gcc (GCC) 3.3.5 (Debian 1:3.3.5-8).
> [...]
> Here is what I get on a machine running 2.6.10 kernel:
> 
> # ./tst
> a = 0, b = 0, a/b = 0
> a = 1, b = 0, a/b = 0
> 
> Someone else tried Intel compiler and it generated code that caused
> floating point exception as it should.
> 
> Something is busted in gcc.

As Andreas pointed out, this code invokes undefined behavior.  Undefined 
here means that the result of an operation is not defined by the language 
standard, and 0 is a valid result when invoking an undefined operation.  

Code relying on undefined behavior is non-portable (or busted, if you 
want) by design.

To quote the standard:

  6.5.5 #3: 

  The result of the / operator is the quotient from the division of the 
  first operand by the second; the result of the % operator is the 
  remainder. In both operations, if the value of the second operand is 
  zero, the behavior is undefined.
 
  Regarding what is undefined behaviour, see 3.4.3: undefined behavior 
  behavior, upon use of a nonportable or erroneous program construct or
  of  erroneous data, for which this International Standard imposes no 
  requirements
 
  NOTE Possible undefined behavior ranges from ignoring the situation 
  completely with unpredictable results, to behaving during translation
  or program execution in a documented manner characteristic of the 
  environment (with or without the issuance of a diagnostic message),
  to terminating a translation or execution (with the issuance of a 
  diagnostic message).

I believe the HP-UX compiler works around this by adding an explicit test 
for every integer divide, and I am not aware of any plans to make a change 
like this to GCC.

Gerald

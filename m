From: Marc Aurele La France <tsi@gpu.srv.ualberta.ca>
Date: Fri, 18 Aug 2000 02:24:52 +0000
Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205352@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 17 Aug 2000, Hiram Clawson, 831-427-7519 wrote:

> Rather than trying to work with the XFree86 X server to fix up this
> loading situation, it is a lot easier to create a couple of tiny
> example programs that dlopen() each other to watch the interaction.

> I believe you are talking about the sequence:

> 	main() dlopens foo0()
> 	foo0() and main() can freely exchange references with each other.
> 	Now foo0() dlopens foo1()
> 	The question is, which of main(), foo0() and foo1() can freely
> 	exchange references with each other ?  Which types of
> 	dynamic loading schemes will allow all loaded programs to share
> 	all symbols.

No, there are actually two problems here.  One is that, in practice, the
use of dlopen() isn't portable because some implementations do not
implement the LAZY flag properly, instead requiring all symbols to be
defined after each dlopen().

The second issue is that there are circular references between certain
XFree86 modules (although, to my knowledge, Michael has yet to run into
them).

As used in XFree86, the dlopen loader is primarily meant to ease
development on new platforms, and, in the end, a publically released
server should not ship with dlopen modules.  Metrolink likely had (has)
other ideas about this, but that's basically how we've used it.  Among
other things, this policy allows us to support OS'es that don't provide
dlopen(), in an OS-independent way.

The dlopen loader does have one advantage, however, that being that a
module's symbols become undefined when the module is unloaded.

Marc.

+----------------------------------+-----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310           |
|  Computing and Network Services  |  fax:    1-780-492-1729           |
|  352 General Services Building   |  email:  tsi@ualberta.ca          |
|  University of Alberta           +-----------------------------------+
|  Edmonton, Alberta               |                                   |
|  T6G 2H1                         |     Standard disclaimers apply    |
|  CANADA                          |                                   |
+----------------------------------+-----------------------------------+
XFree86 Core Team member.  ATI driver and X server internals.



From: m.delahaye@esiee.fr (Matthieu Delahaye)
Date: Wed, 26 Mar 2003 12:09:19 +0000
Subject: Re: [parisc-linux] Re: [Linux-ia64] Linux, Itanium and PA/RISC
Message-Id: <marc-linux-ia64-105590723705316@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705314@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705314@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> You definitely need IA64 Linux to make real use of an Itanium2 Machine.
> (I was able to "play" on an HP 4-Way machine for some weeks.)

I wasn't speaking about real use. Just dirty things. I was also reacting
with David's previous mail.

> [...] 
> As far as I know, the PA-Risc instruction mapping is done with lots of
> software help. The concept is a bit like JIT-Compilers in Java. (It is
> easier to do this when having a RISC code with equal instruction length
> compared to ugly X86 code.) As long as my knowledge is correct, you
> therefore cannot run any PA-RISC OS directly on the Hardware, but you
> can run PA-RISC Software in any OS that supports the instruction
> mapping, maybe one can even run a PA-RISC OS inside a virtual PA-RISC
> Machine on Itaniums. (However I don't know any such VM.)

AFAIK, your knowledge correspond to what I know. Never test hppa
applications, but the intel compiler I had was using 32bits libraries. I
had to extract some of them for my PC to move them on the Itanium. 


So as I said before, I was reacting to David's mail explaining with some
firmware modifications it was possible to do this with an Itanium I,
and he wasn't sure for an Itanium II. Or it is urgent for me to find a
dictionnary. I just add to this (for the foolish who want to try) that
at least it is required to add the chipset support so that the
kernel can boot on Itanium II. That's all.

But please be sure I'm not going to try this unless I want to give to
my boss a good reason to put me out. 
[ This is not because some people reading this list and
working with me wants to test an hppa box resistance by launching it
from the 5th level I'll try to publish slackware installation
screenshots on an Itanium II ].

But perhaps I didn't understand and you told me you already try it
following David's explanation ?

Regards,

Matthieu




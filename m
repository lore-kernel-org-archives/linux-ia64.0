From: Cary Coutant <cary@cup.hp.com>
Date: Fri, 05 Mar 2004 00:05:00 +0000
Subject: Possible race condition with deferred binding on IPF
Message-Id: <BEC72735-6E38-11D8-9E11-003065589C02@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We (HP) have discovered a missing requirement in the psABI document 
with respect to import stubs and inlined import stubs. The deferred 
binding sequence relies on careful ordering of the two stores that 
update the function descriptor in the dynamic loader's 
bind-on-reference routine, and the two loads in the import stub. The 
import stub must load the entry point address, followed by the gp 
value, while the BOR routine must store the gp value first, followed by 
the entry point address. This ensures that one thread cannot interfere 
with another thread if both are making the same call at about the same 
time. Furthermore, we need to ensure strong ordering with the use of 
".acq" and ".rel" completers.

The race condition to be avoided is this:

     Thread 1               Thread 2
     --------               --------
                            load (garbage) gp value
     store new gp value
     store new entry point
                            load (new) entry point

If the loads become visible out of order, and the stores become visible 
between the two loads, we will branch to the actual entry point with a 
garbage gp value. Forcing strong ordering between the two stores and 
between the two loads eliminates the possibility of this ordering 
between the two loads, and therefore eliminates the race condition.

To our knowledge, we have not yet observed an application failure due 
to this problem. We discovered this while finding a compiler bug in 
which the two loads were physically moved out of order by the compiler, 
and came to realize that the psABI does not state any requirement for 
strong ordering.

This problem has potential impact on the following Gnu/Linux components:

- gcc is not affected, since it does not inline import stubs (I think).
- The intel compiler needs to be fixed to generate the necessary 
ld8.acq in inlined import stubs.
- gld needs to be fixed to generate the necessary ld8.acq in the import 
stubs.
- the dynamic loader is not affected, as it uses the required st8.rel 
already.
- handcoded assembly language source is at risk, but inlined import 
stub sequences in handcoded assembly code are, I hope, rare.

While it's clearly important to fix these components, I believe that 
any actual failures due to the missing .acq are so unlikely that there 
is no great urgency to encourage a recompile of the world.

I have proposed the following changes to the IA-64 psABI document:

1. In Section 5.3.6 ("Procedure Linkage Table"), the following 
additional text is needed:

"An import stub (whether in the procedure linkage table or inlined at 
the point of call) must ensure strong ordering between  the load of the 
first doubleword of the local function descriptor and the load of the 
second doubleword. This means that the two loads may not be reordered, 
and the first load must have acquire semantics."

...

"When the dynamic loader updates the local function descriptor entry, 
it must store the second doubleword of the function descriptor (the 
function's gp value) before storing the first doubleword (the function 
address), and the second store must have release semantics, ensuring 
strong ordering between the two stores."

2. The example code in Figure 5-4 needs the ".acq" completer on the 
first load instruction, as follows:

     ...
     .PLT1: (entry for symbol name1)
         addl     r15 = @pltoff(name1), gp ;;
         ld8.acq  r16 = [r15], 8
         mov      r14 = gp ;;
         ld8      gp = [r15]
         mov      b6 = r16
         br       b6
     ...


Cary Coutant
HP-UX Runtime Architect


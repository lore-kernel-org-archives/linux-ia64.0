From: Rahul Chaturvedi <justanotheraliasforrahul@yahoo.com>
Date: Tue, 13 Apr 2004 05:17:22 +0000
Subject: Questions on the stack for IA64
Message-Id: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(***I would appreciate it if you'd cc your reply to
this mail address since I am not a member of this
list***)

I have been trying to figure out exactly how the stack
mechanisms available on IA-64 work internally for a
while now. I've made a few observations which I had a
few questions on,

a.) The stack pointer seems to be r12, which is
pointing to a location along the lines of,

0x60000fffffffxxxx

Shouldn't this address be in the 0x8xxxxxxxxxxxxxxx
range? Isn't the 0x6xxxxxxxxxxxxxxx range reserved for
the data segment?

I also checked the address of a global variable, and
it was stored at in the 0x6xxxxxxxxxxxxxxx range.
Wouldn't the stack and the data segment conflict?

b.) There is something called $GP and $TP that the
compiler defines as r1 and r13 respectively. Anyone
got any idea what they are?

c.) How exactly is the data stored in the bspstore
locations?

d.) The pfs register seems to point to a location in
0xcxxxxxxxxxxxxxxx. Shouldn't this point to some
accessible memory location (from usermode)?

e.) For some reason, compiled code, even with full
optimizations seems to do a "st8" on any value I put
in a local variable. For example, I have a function
with about 40 variables, the intel compiler that I am
using does something like,

mov r47, value
st8 [r48], r47

GCC also does something similar.

Shouldn't the compiler simply store the value in r47
instead of st8'ing it to memory when using full
optimizations (-O2)?


Please forgive me if my questions seem a bit naive, my
experience with IA64 is very limited.


I'd also like to remind you to please CC this address
on your reply :)


Thanks


	
		
__________________________________
Do you Yahoo!?
Yahoo! Small Business $15K Web Design Giveaway 
http://promotions.yahoo.com/design_giveaway/

From: Jack Steiner <steiner@sgi.com>
Date: Tue, 02 Apr 2002 03:11:48 +0000
Subject: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
Message-Id: <marc-linux-ia64-105590701905358@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone seen random SIGILL failures in the strncpy
function in glibc-2.2.4-19.3?

The failure is caused by a NAT consumption fault in the 
code sequence shown below. 

I'm still analyzing the failure, but it _appears_ that the failure 
occurs:
	- if a VHPT fault occurs at <strncpy+450>
	- then a NAT consumption occurs at <strncpy+560>

(preliminary analysis - it may be more complicated than this)

In the failing case, neither source or destination crosses or is
near to a page boundary. Source address is reg 1, dest is the stack in
reg 4. Length 25 bytes.

If no one else has seen this failure, I'll gather more information
about it & try to create a simple failing test case.


We are running 2.4.17 with B0 stepping Itanium.

Note:
	rotating registers/predicates
	speculative loads


	....
	<strncpy+416>:       [MIB] (p16) ld8.s r32=[r20],8
	<strncpy+417>:             (p18) chk.s.i r34,0x20000000001f8c90 <strncpy+944>
	<strncpy+418>:                   nop.b 0x0
	<strncpy+432>:       [MII] (p18) mov r31=r34
	<strncpy+433>:             (p18) czx1.r r24=r34;;
	<strncpy+434>:             (p18) cmp.eq p0,p7=8,r24
	<strncpy+448>:       [MFB] (p18) adds r21=-8,r21
	<strncpy+449>:                   nop.f 0x0
	<strncpy+450>:             (p07) br.cond.dpnt.few 0x20000000001f8b40 <strncpy+608>

	<strncpy+464>:       [MBB] (p18) st8 [r18]=r34,8		<<<--------- if VHPT occurs here

	<strncpy+465>:                   nop.b 0x0
	<strncpy+466>:                   br.ctop.dptk.few 0x20000000001f8a80 <strncpy+416>;;

	<strncpy+480>:       [MFB]       chk.s.m r33,0x20000000001f8cb0 <strncpy+976>
	<strncpy+481>:                   nop.f 0x0
	<strncpy+482>:                   nop.b 0x0
	<strncpy+496>:       [MFB]       mov r31=r33
	<strncpy+497>:                   nop.f 0x0
	<strncpy+498>:                   nop.b 0x0
	`
	<strncpy+512>:       [MIB]       cmp.eq p5,p6=r21,r0
	<strncpy+513>:                   adds r21=-1,r21
	<strncpy+514>:             (p05) br.cond.dptk.few 0x20000000001f8bf0 <strncpy+784>;;

	<strncpy+528>:       [MFI]       nop.m 0x0
	<strncpy+529>:                   nop.f 0x0
	<strncpy+530>:                   mov.i ar.lc=r21

	<strncpy+544>:       [MII]       nop.m 0x0
	<strncpy+545>:             (p06) extr.u r27=r31,0,8
	<strncpy+546>:             (p06) shr.u r31=r31,8;;

	<strncpy+560>:       [MIB]       st1 [r18]=r27,1     <<<<<<<<<<<<<<<<<<<< fails here





-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      Core OS/Strategic Software Org
SGI - Silicon Graphics, Inc.            Eagan, MN



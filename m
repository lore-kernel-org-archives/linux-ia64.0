From: "Zagorodnev, Grigory" <Grigory_Zagorodnev@stl.sarov.ru>
Date: Thu, 28 Feb 2002 12:02:03 +0000
Subject: RE: [Linux-ia64] problem with unwind info for .init/.fini section
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C1C04F.BC055520"
Message-Id: <marc-linux-ia64-105590701905199@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905179@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905179@msgid-missing>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C1C04F.BC055520
Content-Type: text/plain;
	charset="koi8-r"

More about .init/.fini
----------------------
Guess you already know, but anyway...

There are two special funtions defined by ELF ABI - _init and _fini. First
one is calling at loadable module (executable or shared library) load time,
sencond one - at unload time. Let's call it "ELF feature".

GNU C run-time library uses this feature to provide initialization mechanism
for other libraries and user code. GNU C startup code defines prologue and
epilogue for functions _init and _finit in sections .init and .fini
correspondingly. Any other object file or library could provide body for
desired function in specified section.

Such approach eliminates exclusive use of ELF feature within the
application. 
Given technique is actually using by GNU C and GNU C++ run-time libraries.

The problem
-----------
Unfortunatelly, GNU C startup code does not provide unwind information for
_init and _fini routines. That falls us to stack unwinding problem.

Options
-------
There are two addition directions to go around the problem I see:
	3) Modify glibc to avoid such hacking
	4) Modify debuger(unwinder) algorithm

For and against
---------------
First of all, is the additional note to proposal #1 (to modify linker).
1) Don't think linker is able to generate more then just frame description.
Only compiler can produce ALL necessary unwinding information.

3) More preferable solution. Guess it's possible to provide another
technique of ELF feature using, which will satisfy debuger. Why don't you
contact glibc people for it?

4) I think it's possible to workaround the init/fini problem inside debuger
itself.
Note that .init and .fini sections are dedicated for given functions only. 

It means that the beginning of _init routine coincides with the beginning of
.init section, length of _init routine equals to length of .init section and
any IP from this range belongs to _init routine body. Same situation with
_fini routine and .fini section.

Such knowledge makes possible to determinate _init/_fini frame during
unwinding.
But there is still no chance to go below _init/_fini routine since there is
no unwinding information for it.

Note: remember that each loadable module has own _init/_fini pair in own
.init/.fini sections.

And, finally, is there a way for "alternative" unwinding on ia64 (with
missing unwind info)? 

Grigory.


-----Original Message-----
From: David Mosberger [mailto:davidm@hpl.hp.com]
Sent: Friday, February 22, 2002 10:54 PM
To: binutils@sources.redhat.com
Cc: linux-ia64@linuxia64.org
Subject: [Linux-ia64] problem with unwind info for .init/.fini sections


I mailed the attached article to libc-hacker yesterday, but forgot to
cc the binutils list.  I'd really appreciate hearing other people's
ideas on how to fix this problem.  While we found the problem with
ia64 linux, I suspect other platforms that rely on unwind info are
likely to be affected as well.

Thanks,

	--david

---
Today I noticed that the .init and .fini sections are lacking the info
needed for reliably unwinding on ia64.  This turns out to be a
somewhat nasty problem to solve, because the section is generated at
linktime.  It's easy to fix up the unwind info for the init/fini
prologues, but it's less clear what to do about the body of these
sections.  I can think of two approaches:

 (1) Change the linker so it updates the unwind info once the final
     .init/.fini section has been created.  This shouldn't be all
     that hard: it requires updating the unwind table entry and
     adjusting the unwind descriptors so that the final body region
     is long enough to cover the entire section.

 (2) Require that each code fragment that goes into the .init/.fini
     section is wrapped like this:

		.proc whatever
		.prologue
		.vframe r32
		.save rp, r33
		.save ar.pfs, r34
		.body
		  :
		ACTUAL INIT CODE
		  :
		.endp

(2) might be somewhat easier to do, but is less efficient (the same
unwind info gets duplicated over and over again for no good reason)
and finding all code sequences that go into .init/.fini would be hard
(e.g., it would require gcc, for sure).

(1) doesn't strike me as a great solution as it would require building
more special-section knowledge into the linker, but the solution would
probably be more reliable and more localized than (2).

Anybody else have a better idea or other comments?

	--david

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

------_=_NextPart_000_01C1C04F.BC055520
Content-Type: application/ms-tnef
Content-Transfer-Encoding: base64

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
AEdSSUdPUlkAAwAaQAAAAAAeADBAAQAAAAgAAABHUklHT1JZAAMAGUAAAAAAAwCAEP////8LAPIQ
AQAAAAIBRwABAAAALgAAAGM9UlU7YT0gO3A9SU5URUw7bD1PRFlTU0VZLTAyMDIyODEyMDIwM1ot
NDQ3MAAAAAIB+T8BAAAARwAAAAAAAADcp0DIwEIQGrS5CAArL+GCAQAAAAAAAAAvTz1JTlRFTC9P
VT1TQVJPVi9DTj1SRUNJUElFTlRTL0NOPUdSSUdPUlkAAB4A+D8BAAAAFAAAAFphZ29yb2RuZXYs
IEdyaWdvcnkAHgA4QAEAAAAIAAAAR1JJR09SWQACAfs/AQAAAEcAAAAAAAAA3KdAyMBCEBq0uQgA
Ky/hggEAAAAAAAAAL089SU5URUwvT1U9U0FST1YvQ049UkVDSVBJRU5UUy9DTj1HUklHT1JZAAAe
APo/AQAAABQAAABaYWdvcm9kbmV2LCBHcmlnb3J5AB4AOUABAAAACAAAAEdSSUdPUlkAQAAHMEIb
67tPwMEBQAAIMDrGHb5PwMEBHgA9AAEAAAAFAAAAUkU6IAAAAAAeAB0OAQAAAD8AAABbTGludXgt
aWE2NF0gcHJvYmxlbSB3aXRoIHVud2luZCBpbmZvIGZvciAuaW5pdC8uZmluaSBzZWN0aW9ucwAA
HgA1EAEAAAA+AAAAPDUxNTI0QjZDNjg5RUQ0MTE4RDRGMDA5MDI3M0FDRTMyOTI4NzVEQG9keXNz
ZXkuc3RsLnNhcm92LnJ1PgAAAAsAKQAAAAAACwAjAAAAAAADAAYQKf/L3gMABxDyDQAAAwAQEAAA
AAADABEQAAAAAB4ACBABAAAAZQAAAE1PUkVBQk9VVElOSVQvRklOSS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS1HVUVTU1lPVUFMUkVBRFlLTk9XLEJVVEFOWVdBWVRIRVJFQVJFVFdPU1BFQ0lBTEZVTlRJ
T05TREVGSU4AAAAAAgF/AAEAAAA+AAAAPDUxNTI0QjZDNjg5RUQ0MTE4RDRGMDA5MDI3M0FDRTMy
OTI4NzVEQG9keXNzZXkuc3RsLnNhcm92LnJ1PgAAADtr

------_=_NextPart_000_01C1C04F.BC055520--


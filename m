From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 22 Feb 2002 19:54:27 +0000
Subject: [Linux-ia64] problem with unwind info for .init/.fini sections
Message-Id: <marc-linux-ia64-105590701905179@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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


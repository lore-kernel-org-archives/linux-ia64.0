From: Peter Bergner <bergner@vnet.ibm.com>
Date: Mon, 21 Jan 2002 18:48:19 +0000
Subject: [Linux-ia64] IA64 ELF header question...
Message-Id: <marc-linux-ia64-105590698805902@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Does anyone know whether the e_entry field in the IA64 ELF header
is equal to the address of the function descriptor of the _start
routine or whether it's equal to the address of the _start code?
(ie, ._start)  Looking at the IA64 kernel and GLIBC sources
(the IA64 ABI was a little vague), I'm guessing e_entry is actually
the address of the _start code (ie, e_entry = address of ._start).

The reason I ask, is that I'm working on the PPC64 GLIBC port
and our ABI states that our e_entry field is equal to the
address of the function descriptor for _start.  This was fine
for statically linked apps.  All we needed to change in the
kernel was an extra dereference in start_thread to load the
actual code address of _start and away we went.

My problem is with dynamically linked apps.  The kernel is smart
enough to know when it loads ld.so to reloc the e_entry field.
The problem is that the function descriptor entries for _start
need to be reloc'd too before we can use them.  I'd prefer not
to touch arch independent code to fix this, but it doesn't look
like I have enough info in start_thread to determine whether
I need to reloc the function descriptor entries or not before
using them.  Since PPC64 and IA64 share the use of function
descriptors, I thought I'd check with people here on how this
was solved for IA64.  Anyone have any ideas I can use?

...I guess another option I could try is to change the PowerPC64-ELF
ABI to say that the e_entry field holds the address of ._start
rather than _start.  Although, I'm not sure whether that's possible
or not.


Peter

--
Peter Bergner
SLIC Optimizing Translator Development / Linux PPC64 Kernel Development
IBM Rochester, MN
bergner@vnet.ibm.com


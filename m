From: "Zorn, Brian E" <brian.e.zorn@intel.com>
Date: Sat, 07 Jul 2001 17:10:37 +0000
Subject: [Linux-ia64] IA64 Stack Unwind on RedHat Linux
Message-Id: <marc-linux-ia64-105590693005824@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi All,

In RedHat Linux, I'm working with a software vendor who is looking for
information on an API for finding the stack unwind table, provided by the
dynamic loader.  If this is available now, any information on where to get
it and how to use it would be greatly appreciated.  If this is not currently
available, could someone please provide me with an expected date when it
will be, so that the vendor can plan their product roadmap more effectively?

Here's some further clarification of the issue from the software vendor:

The information we need is the procedure/API for finding the unwind table
associated with a given instruction pointer under Linux for IA-64. The
documentation on IA-64 stack unwinding says this information is necessary
for stack unwinding, but is OS-specific and not given in the Intel manuals:
Specifically, in Section 11.1.2 of the IA-64 Software Conventions and
Runtime Architecture Guide, it says "...the dynamic loader is expected to
provide an API for finding the unwind table, given a known IP. This API is
specific to the operating environment, and is not described here."

Here's a description of what they did on Linux/x86:

When someone allocates memory we get a list of address. Each address is the
return address to the previous stack frame. The entire list should
describe the entire calls stack of the call to "malloc". When an
"interesting event" happens to the memory allocated, we go through the list
of pointers. For each address we find the relevant symbol, module, and
line information if available.

This is roughly what we do on linux/x86

void* getSp() {
asm("mov %ebp, %eax");
}

void *unwindStack() {
void * sp = getSp;
void stack[100];
int i = 0;

// limit is some value beyond which the stack is not interesting
while (sp > limit) {
// The return address is the second word of the stack frame
stack[i++] = sp + 1;

// The first word of the stack frame is the address of the
previous stack frame.
sp = *(void **)sp;
}

return stack;
}
**********************************************
Thanks for your help,

Brian E. Zorn
Application Engineer				Phone:	503-264-6218
Core eTools - Oregon				email:
brian.e.zorn@intel.com <mailto:brian.e.zorn@intel.com>
Solutions Enabling Group
Intel Corporation





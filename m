From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 03 Jul 2001 22:58:34 +0000
Subject: RE: [Linux-ia64] patching sys_call_table from a module
Message-Id: <marc-linux-ia64-105590693005815@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005808@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005808@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It looks like you can't do this easily right now.  As others
have pointed out, on IA64 a pointer to a function is actually
a pointer to a two element structure that contains the actual
function address, and the gp value to use for that function.

However, sys_call_table in the kernel is not currently implemented
as a real "array of pointers to functions" ... it is simply an
array of function addresses ... and the code in ivt.S that makes
the branch through the pointer when a user invokes a system call
knows this.  So the ivt.S code just leaves "gp" unchanged ... which
works for all system calls that are staticly linked into the kernel,
but means that system calls in modules are in trouble as they will
be invoked with the kernel "gp" instead of their own, and they will
fault as soon as they try to access any data objects that belong to
the module.

You might be able to workaround this for now by providing a stub
function in your module that sets "gp" and calls your real function.

Probably the real fix would be to change sys_call_table and ivt.S to
make them follow the usual ia64 conventions for pointers to functions.


-Tony Luck

-----Original Message-----
From: chas williams [mailto:chas@cmf.nrl.navy.mil]
Sent: Tuesday, July 03, 2001 6:46 AM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] patching sys_call_table from a module



afs patches the sys_call_table to provide support for various functions.
the existing doesnt seem to work right.  i figured out that the ia64
calls are offset by 1024.  but know i have a different problem:




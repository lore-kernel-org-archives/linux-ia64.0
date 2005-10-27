From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 27 Oct 2005 18:03:46 +0000
Subject: RE: [PATCH 1/2] ia64: ptrace - find memory sharers on children list
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04CC07FB@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4360F244.mailxI4A11KHTU@eag09.americas.sgi.com>
In-Reply-To: <4360F244.mailxI4A11KHTU@eag09.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>The ptrace caller (presumably a debugger) specifies the pid of
>its target and an address to peek or poke.  But the debugger could be
>attached to several tasks.

Perhaps I'm being overly dense here (I haven't ever tried to
debug a multi-threaded application) ... but how can this situation
happen?  Since ptrace takes a "pid" argument, I'd expect that any
activities performed by the kernel in response to that ptrace call
would be restricted to just the process that was mentioned.  Searching
off through other processes to see if any of them have the data
just sounds wrong.  Why can't the debugger keep track of which
process is which and give the right "pid" to the ptrace call?

-Tony

From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 03 Nov 2000 02:19:22 +0000
Subject: [Linux-ia64] Re: gdb null ptr
Message-Id: <marc-linux-ia64-105590678205647@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't see how this can happen from looking at the source.  We only cache
a type in dwarf2_cached_types if it has a DW_AT_name attribute, and if it
does have such an attribute, then the type should have a name or tag name.

Can you provide me with a testcase?  A binary that I can run under gdb should
be sufficient.  You could put it in ftp.cygnus.com/incoming and then mail
the file name to me.

Since this doesn't appear to be an ia64 specific problem, if I don't have a
testcase then I will just punt to the gdb developers
	 http://sources.redhat.com/gdb/#bugs

Jim


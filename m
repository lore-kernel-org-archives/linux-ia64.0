From: Jim Wilson <wilson@redhat.com>
Date: Fri, 29 Mar 2002 03:00:33 +0000
Subject: Re: [Linux-ia64] debuggers
Message-Id: <marc-linux-ia64-105590701905344@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905343@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905343@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Besides gdb and ddd what other types of debuggers are available for IA64?

ddd is a graphical front end for debugggers, it isn't a debugger itself.
If you are using ddd, then you are likely still using gdb underneath as
the real debugger.  If you want a list of gdb front ends... there is an emacs
gdb mode which is the front end that I use.  There is gdbtk which is a
graphical X windows front end that uses tcl/tk.  There is also a curses based
text window front end called tui, originally from HP, but I've never used that
one so I don't know anything about it.

As for other debuggers besides gdb, I know that Intel has one which comes
with the Intel compilers.  It implements a gdb-like command set.  This debugger
is called LDB, the Linux debugger.

There are of course other debuggers for other operating systems, but they
aren't useful on ia64-linux systems.

Jim


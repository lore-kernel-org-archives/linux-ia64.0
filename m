From: piet delaney <piet@freebsd.piet.net>
Date: Fri, 29 Mar 2002 22:23:09 +0000
Subject: Re: [Linux-ia64] debuggers - ia64 gdb stubs?
Message-Id: <marc-linux-ia64-105590701905345@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 28, 2002 at 07:00:33PM -0800, Jim Wilson wrote:
> >Besides gdb and ddd what other types of debuggers are available for IA64?
>
> ddd is a graphical front end for debugggers, it isn't a debugger itself.
> If you are using ddd, then you are likely still using gdb underneath as
> the real debugger.  If you want a list of gdb front ends... there is an emacs
> gdb mode which is the front end that I use.  There is gdbtk which is a
> graphical X windows front end that uses tcl/tk.  There is also a curses based
> text window front end called tui, originally from HP, but I've never used that
> one so I don't know anything about it.
>
> As for other debuggers besides gdb, I know that Intel has one which comes
> with the Intel compilers.  It implements a gdb-like command set.  This debugger
> is called LDB, the Linux debugger.
>
> There are of course other debuggers for other operating systems, but they
> aren't useful on ia64-linux systems.

I was currious if anyone else interested-in/working-on a gdb stub for ia64?

I've been modifying the i386 version of a kdb to gdb stub, skdb, to work
on the ia64, and was thinking of playing around this weekend a bit and
sorting out register assignment problems. I just thought I'd see if anyone
else was interested-in or working-on this or a direct ia64_stub.c for gdb
for the public domain.

Seems strange that a google search still only shows myself when I search on the
{ia64 gdb stub} keywords. I'd just like double check and avoid duplicating effort.

HP has an exceptional version of GDB, KWDB, that can do src debugging
over the internet and it appears to have been ported to ia64. Unfortunately,
the stub doesn't appear to be under the GNU copyleft.

-piet
~


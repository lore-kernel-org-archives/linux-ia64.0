From: Don Dugger <n0ano@valinux.com>
Date: Wed, 10 Jan 2001 21:51:07 +0000
Subject: Re: [Linux-ia64] IA-64 Linux TODO list
Message-Id: <marc-linux-ia64-105590693005018@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205896@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All-

OK, I got the web page up with the TODO list on it.  You can link
to it from `www.linuxia64.org' or go directly to the page at
`www.linuxia64.org/todo.html'.  Check it out and let me know if
there are any changes or additions.  Some obvious changes are we
need some volunteers for `EEPro100', `execve' and `gprof' - any
takers?

In addition to the web page I plan on sending out a text copy of
the list to this mailing list on a bi-weekly basis.

On Tue, Jan 09, 2001 at 11:23:23AM -0800, David Mosberger wrote:
> Since we're getting closer to a real release of various IA-64 Linux
> distros, I thought it would be a good idea to pass around my TODO
> list.  I'd really appreciate if someone else could maintain this list
> and mail it out periodically (weekly?) as my bw is pretty limited
> right now.  Here is what comes to mind:
> 
> Kernel
>  - enable kernel unaligned handler
>  - verify that all on-board hardware is supported and working:
> 	- does cs4281 sound driver work reliably now?
> 	- what to do about eepro100? (currently hangs on > 180MB transfers?)
>  - investigate and fix test suite failures reported by SCO (Who's the
>    contact person at SCO for this?  Please make available simple test
>    cases that reproduce the problem so we can go about fixing them.)
>  - consider clearing CPU state on an execve() to avoid leaking information
>    to a new program; Alan Cox thinks it would be sufficient to do this
>    when current->dumpable is zero
> 
> Libraries
>  - gprof support?
> 
> Apps
>  - gdb
>     - NaT bits don't seem to work properly?
>     - coredump support still broken?
>  - strace
>     - 'strace -f' hangs if the program forks a child;
>     - verify that the new system calls have been added
> 
> I'm planning to work on the kernel unaligned handler but if someone
> else is dying on doing that, let me know. ;-)
> 
> If you can think of anything else, please let me know---I'll try keep
> the list uptodate for now.
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838


From: Al Stone <ahs3@fc.hp.com>
Date: Tue, 19 Oct 2004 22:48:49 +0000
Subject: Re: [Gelato-technical] q-tools v0.2 released
Message-Id: <1098226129.4421.21.camel@fcboson.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Experimental versions of ia64 Debian packages for q-tools v0.2
are now available, too.  You will need to be running Debian
unstable (aka 'sid') and a 2.6 kernel for the packages to work
properly.

You can pick up all the bits and pieces at:

   http://free.linux.hp.com/~ahs3/q-tools

Or, you can use apt-get to install the tools.  Add the following
to your sources.list file:

   deb http://free.linux.hp.com/~ahs3 /
   deb-src http://free.linux.hp.com/~ahs3 /

Then:

   # apt-get update
   # apt-get install q-tools

Feel free to let me know if there are any problems with these packages.

On Mon, 2004-10-11 at 09:52, David Mosberger wrote:
> I'm happy to announce that q-tools v0.2 has been released.  q-tools is
> a collection of Linux performance analysis tools.  In particular, they
> include q-syscollect and q-view, which can be thought of as being more
> powerful than gprof, without its pain (no recompilation needed;
> multi-threaded apps and shared libraries are supported;
> kernel-execution can be profiled; any Itanium 2 PMU event can be
> profiled, etc.).
> 
> As usual, you can get q-tools via the web page at:
> 
> 	http://www.hpl.hp.com/research/linux/q-tools/
> 
> It may take a couple of hours before the web pages migrate across the
> firewall but in the meantime you may also get the q-tools-0.2 tar-ball
> directly from the ftp site:
> 
> 	ftp://ftp.hpl.hp.com/pub/linux-ia64/
> 
> There are two major enhancements in this release:
> 
>  - SuSE Enterprise Linux 9 (SLES9) is now supported out-of-the-box
>    (in addition to the existing Debian support)
> 
>  - q-syscollect now has the ability to profile the time spent in
>    code which has interrupts disabled (see section
>    "Blind-spot-free profiling" in the README for details).
> 
> In addition, there are many bug-fixes, in particular some nasty bugs
> in q-syscollect got fixed which reared their ugly face primarily on
> large SMP machines.
> 
> For additional details, I attached the relevant section from the NEWS
> file.
> 
> Enjoy,
> 
> 	--david
> 
> ----
> * News for v0.2:
> 
> ** New features
> 
> *** q-syscollect: Add support for interruption-level code-sampling (-i option).
> *** q-tools now builds and works out-of-the-box for SuSE (SLES 9).
> 
> ** Bug fixes
> 
> *** q-syscollect: Make it robust against small RLIMIT_MEMLOCK values.
> *** q-syscollect: Fix bug which could cause killing of "random" processes.
> *** q-syscollect: Fix bug which could cause live-lock when the
>                   sampling-buffer filled up.
> *** q-syscollect: Fix a memory leak.
> *** q-syscollect: Fix handling of backslashes in argument vectors.
> *** q-view: Ignore non-function symbols to avoid confusion when a function
>             contains a local lable.
> *** q-view: Fix topological sort of the call-graph for good.
> *** q-view: Ensure weird symbols such as "operator|=" get parsed properly.
> *** q-view: Display fully-qualified kernel symbols as SYMNAME<kernel> for
>             consistency.
> *** q-view: Build symbol table more carefully, e.g., suppressing duplicates
>             and use unwind-info to detect procedure-boundaries in stripped
>             binaries.
> *** q-view: Allow for multiple kallsyms-formated symbol-files to enable,
>             e.g., firmware symbol-tables.
> 
> _______________________________________________
> Gelato-technical mailing list
> Gelato-technical@gelato.unsw.edu.au
> https://www.gelato.unsw.edu.au/mailman/listinfo/gelato-technical
-- 
Ciao,
al
----------------------------------------------------------------------
Al Stone                                      Alter Ego:
Linux & Open Source Lab                       Debian Developer
Hewlett-Packard Company                       http://www.debian.org
E-mail: ahs3@fc.hp.com                        ahs3@debian.org
----------------------------------------------------------------------


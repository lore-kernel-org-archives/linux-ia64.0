From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 03 Apr 2004 05:57:20 +0000
Subject: q-tools-0.1 released
Message-Id: <200404030557.i335vK93030523@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

v0.1 of q-tools has been released.  This is mostly a bug-fix release
and as such has no major new features.  A lot of small and
not-so-small bugs should be fixed though and I'd generally recommend
upgrading.  For details, see the relevant portion of the NEWS file
below.

There is also the beginning of a web site:

	http://www.hpl.hp.com/research/linux/q-tools/

as usual, it may take a few hours before the pages make it across
the firewall.  In the meantime, you can always get the latest file
directly from the HP Labs ftp server:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/

Enjoy,

	--david

-------------------------------------------------------------------
* News for v0.1:

** New features

*** q-syscollect command line is now captured, too

The command-line with which q-syscollect was invoked is now also
dumped into each .info file.  The tag under which the command
line is stored is:

     q:syscollect-cmdline

*** The format of fully-qualified symbols changed in q-view

q-view now displays fully-qualified symbols as:

  SYMBOLNAME<OBJECTNAME>

instead of

  OBJECTNAME:SYMBOLNAME

For example, instead of "libunwind.so.1:run_script" it would print
"run_script<libunwind.so.1>".  This enhancement is believed to improve
the readability of the output.

*** New option -m/--merge-unknown

With this option turned on, processes that are too short-lived for
q-syscollect to capture their info (/proc/PID/maps and
command-line-info) will have their profile data gathered into a single
file called "unknown-cpuN.info".  This avoids creating hundreds of
separate files when there are hundreds of too short-lived processes.

*** New program q-grab-mappings

See README for description.

** Bug fixes

*** q-view: Fix a bug which occasionally caused a symbol to get lost.
*** q-view: Fix a potential division-by-zero bug.
*** q-syscollect: Fix file-descriptor leak in elf_valid_file().
*** q-syscollect: Don't dump coare if sysconf(_SC_NPROCESSOR_ONLN) lies

*** q-syscollect: Don't ignore anonymous mappings entirely

This fixes a performance bug in which dynamically-generated code could
lead to /proc/PID/maps being re-read way too frequently (XFree86 was a
good way to trigger this problem, due to it's in-house dynamic
loader).


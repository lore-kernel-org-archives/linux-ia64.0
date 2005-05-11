From: Keith Owens <kaos@sgi.com>
Date: Wed, 11 May 2005 04:40:58 +0000
Subject: Re: KDB improvements for IA64
Message-Id: <10479.1115786458@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4280D2C5.3060604@bull.net>
In-Reply-To: <4280D2C5.3060604@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 09 May 2005 10:32:54 +0200, 
Francois Wellenreiter <Francois.Wellenreiter@bull.net> wrote:
>	I have been working during the last months for improving KDB product
>on IA-64 architecture.
>
>The version I propose to you here solves different problems and implements new
>features such as :
>
>- breakpoint misfunctioning on SMP machines
>
>	The global KDB entry and exit sequences have been deeply modified.
>The flag set has been reduced to the minimum and spinlock usage had increased.
>
>- "ssb" command is now implemented for IA64.
>	Step to taken branch  feature did not exist on the SGI KDB version.
>It is working by now, using the taken banch bit in the control register.
>
>- timeouts when exiting from KDB will never occur
>	I have noticed that after a long time in KDB, some drivers enter
>in timeout sequences. Now, the different ITC values are saved when entering KDB
>and restored when going out.
>
>I have done many tests on Intel Tiger and Bull Novascale machines and
>the results I obtain seem to prove that this version is now stable.
>
>That is the reason why I invite you to test it. Do not to hesitate to give me
>your feedback and your comments.
>
>However, the modifications I have done only work for IA64 based machines.
>Since I have no IA32 machine to modify and test it, I can not do anything
>for this architecture, unless you can give me a PC.

I have compared your versions against the standard kdb v4.4 2.6.12-rc2
patches and gone through your changes.  Unfortunately you lumped them
all together which made it very difficult to work out what you were
changing.  AFAICT, you have these changes :-

* Lots of whitespace changes, including changing indentation,
  reformatting function calls, reformatting function declarations,
  converting tabs to spaces and even adding whitespace to the end of
  lines.  Never change whitespace at the same time as making other
  changes, it makes it extremely difficult to see what has really
  changed.

* Saving and restoring itc around kdb.  That only works for
  architectures where you can overwrite the source of get_cycles().  On
  i386, TSC is read only so this approach does not work there, and I do
  not like workarounds that only work on some architectures.  If there
  are time critical bits of code that cannot tolerate long delays then
  the solution is to provide a mechanism for all debug and dump code
  (not just kdb) to reset the timers at the OS level, not at the
  hardware level.

* Variables and functions got renamed.  Why?

* The entire kdb state diagram was redone.  That may or may not be
  useful, but without any discussion on what you are trying to achieve,
  I cannot tell if the new state diagram is right.  I do know that you
  deleted some states that are still required

* Every registered command get a new int * parameter, which is unused
  in all but one command.  I cannot even tell what you are trying to do
  with that extra option, it seems to be tied into the undocumented
  state diagram changes.  That change will break every other piece of
  code that adds its own commands to kdb.  A lot of subsystems take
  advantage of kdb to provide the debugging fraemwork, breaking the ABI
  like this is not acceptable.

* The meaning of KDB_ENTER() was changed.  The new version will cause
  problems when KDB_ENTER() is used on paths that kdb also uses, you
  will get recursive entry and deadlock

* The test for WARN_CONSOLE_UNLOCKED() was changed.  I expect that to
  generate lots of spurious warning messages on VGA consoles.

* kdb_notifier_list was removed.  That is used by some subsystems to
  get notification of entry to and exit from kdb.  It is required.

* Support for the ppc64 and sparc64 consoles was removed from
  kdb_printf().  That support is required.

* You removed all the "pause output after LINES lines" code and the
  associated CMD_INTERRUPT flag.  That code is the only thing that
  catches output from runaway commands, it is required.

* Bits of the catastrophic error handling were deleted, it is now
  incomplete.

* XScale support has been removed from the main kdb control loop.

* Breakpoint handling has been redone.  Alas with all the other
  changes, I cannt tell which changes are for breakpoint handling so I
  cannot tell if they work or not.

There are far too many changes in the Bull patches; many of these
changes are spurious or simply wrong.  I am rejecting these patches.
If you want to redo the breakpoint handling then that is fine, but make
that change on its own and discuss the change on the list first.

Keith Owens.


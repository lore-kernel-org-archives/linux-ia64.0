From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Jun 2006 05:57:14 +0000
Subject: RE: Question about the segment [[ 60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00 0 ]]
Message-Id: <617E1C2C70743745A92448908E030B2A0EE79D@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> RSE backing store.
>
> Can you tell me where I can find more information about  this?

Section 4.1 of volume 1 of the Itanium Software Developers Manual
(you can download in PDF form from http://www.intel.com/design/itanium/manuals/iiasdmanual.htm)

> My application is similar to unexec of emacs, tries to save all the
> segments in the map file and restore them back, while restoring
> currently we assume that if the segment is above sbrk(0) then it needs
> to be mmap'ed from the save file else override it.

You'll need to look more closely at bits from /proc/$$/maps
to figure out some heuristic ... a simple comparison against
the address of sbrk(0) isn't going to cut it (as you have
alreasdy figured out).

> Looks like If I dont overwrite the RSE backing store fclose on my open
> files seem to crash when I restore my program.

Hmmm, sounds like some interesting code would be needed to do
this.  When saving, you'd need to make sure that all state
was flushed out of the stacked registers into memory.  You'd
also need to save the values of ar.bspstore etc. that refer
to the RSE backing store.  On resume, you'd need to restore
the registers.  Perhaps some creative use of setjmp/longjmp
might allow you to avoid coding this up in assembler?  But I'm
not quite sure whether that would handle everything for you.

-Tony

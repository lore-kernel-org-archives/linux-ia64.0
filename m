From: John Hesterberg <jh@sgi.com>
Date: Tue, 27 Nov 2001 17:02:54 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.16)
Message-Id: <marc-linux-ia64-105590698805550@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 27, 2001 at 02:04:15PM +0100, Andreas Schwab wrote:
> David Mosberger <davidm@hpl.hp.com> writes:
> 
> |> An updated ia64 patch for 2.4.16 is now available at
> |> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/ in file:
> |> 
> |>         linux-2.4.16-ia64-011126.diff*
> |> 
> |> change log:
> |> 
> |> 	- update for 2.4.15/2.4.16:
> |> 		- add show_trace_task()
> |> 		- lots of SGI SN updates (most in "sn" subdirectories)
> |> 		- IA-32 brk() fix by Don Dugger
> |> 	- drop some of the more cosmetic fixes (they will be in the 2.5 tree
> |> 	  instead)
> |> 	- fix EARLY_PRINTK (Tony Luck, I think)
> |> 	- in iosapic.c, move RTE programming to a saner place (Alex Williamson)
> |> 	- fix alignment of bootmap
> |> 	- move machvec_init() a little earlier and call platform_cpu_init() at
> |> 	  end of cpu_init() (Jack Steiner)
> |> 	- swiotlb.c: support "page" member in scatterlist
> |> 	- fix asm clobbers in spinlock.h
> |> 	- add more ACPI tables to asm-ia64/acpi-ext.h
> |> 
> |> This kernel has been tested with gcc-3.0 on Big Sur and HP Ski
> |> simulator.  As usual, your mileage may vary.
> 
> You have renamed numnodes in mm/numa.c, but not in include/linux/mmzone.h,
> and there are many occurences of "extern int num_compact_nodes" all over
> the place.  I'm wondering why it was renamed in the first place.
> 
> Andreas.

It was changed because numnodes is ambiguous.  This is part of a
significant numa/discontig memory change that will be submitted to
the ia64 2.5 tree.  This little piece came in as part of the SGI SN
updates, since it's more clear, and the SN code has lots of
references to it, and only a couple in the non-SN code.
Of course, as you point out, I didn't get the mmzone.h change in
right, I'll send an update for that.

The numa/discontig work is part of the Linux Scalability Effort
that is on sourceforge.  For details, see:
    http://sourceforge.net/projects/discontig
The latest patch is:
    http://prdownloads.sourceforge.net/discontig/discontig-2.4.14.gz
    
    John


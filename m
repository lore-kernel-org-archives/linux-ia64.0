From: Khalid Aziz <khalid_aziz@hp.com>
Date: Mon, 15 Nov 2004 22:14:51 +0000
Subject: RE: [PATCH] kexec on ia64
Message-Id: <1100556891.26292.42.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100550721.26287.32.camel@lyra.fc.hp.com>
In-Reply-To: <1100550721.26287.32.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-11-15 at 14:15, Luck, Tony wrote:
> >Here is what I am working on next:
> >
> >1. Save EFI memory map before it is trimmed.
> 
> This code has been "evolving" for a long time now, more layers
> get addded to solve each new problem.  If you get time, please
> step back about a half-mile and take a look at the big picture
> and see you you can see a better way to do the scanning and
> trimming and re-scanning.  The overall problem statement (ignore
> anything except complete granules, honour the command-line arguments
> max_mem/max_addr, allocate a temporary bitmap for bootmem) seems
> like it shouldn't require such complex code :-)  You can add your
> own new requirement to not modify the original EFI tables so that
> they can be re-scanned by a new kernel after kexec (new kernel
> might have a different granule size).
> 
> -Tony

Tony,

I definitely like this idea better. I have been talking to another
developer who is struggling with efi_mem_map_walk() trimming original
EFI memory map for "mem=" and "max_addr=". We have discussed separating
efi_mem_map_walk() into three separate routines, one to simply walk
memory map and compute the physical memory size without touching map,
one to trim memory map for granule size and one to trim memory map for
"mem=" and "max_addr=". This will allow us to save an untouched memory
map in between calls to these routines. Now that I know you guys are
open to something like this, we will pursue it further :)

-- 
Khalid

==================================
Khalid Aziz                                Linux and Open Source Lab
(970)898-9214                                        Hewlett-Packard
khalid_aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
				- Alessandro Rubini



From: Paul Jackson <pj@sgi.com>
Date: Sat, 01 May 2004 08:33:04 +0000
Subject: Re: arch/ia64/ia32/binfmt_elf32.c: elf32_map() broken ia64 build
Message-Id: <20040501013304.32a750d3.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040426185633.7969ca0d.pj@sgi.com>
In-Reply-To: <20040426185633.7969ca0d.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, jreiser@BitWagon.com, mike@navi.cx, pageexec@freemail.hu, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Raj, Ashok" <ashok.raj@intel.com>

It's worse than I realized when I started this lkml thread (now adding
linux-ia64 to cc list because I likely need ia64 maintainers assistance).

Not only don't the bssprot patches in Andrew's 2.6.6-rc2-mm2 not build,
they don't boot on SGI's SN2 ia64 with sn2_defconfig.  If I remove these
4 bssprot patches, then 2.6.6-rc2-mm2 builds (with the easy build fixes
already understood earlier this week) and boots on SN2 ia64 with
sn2_defconfig.

The 4 patches in question are named in Andrews 2.6.6-rc2-mm2 series file:

   bssprot.patch
   bssprot-sparc-fix.patch
   bssprot-cleanup.patch
   bssprot-more-fixes.patch

If I apply the cheap bssprot fix, changing the signature of the function
elf32_map() in arch/ia64/ia32/binfmt_elf32.c as noted earlier in this
lkml thread, then yes I can build it, including these patches, for
sn2_defconfig.

But trying to boot the resulting kernel on an SGI SN2 system fails.  The
boot successfully prints out:

  Freeing unused kernel memory: 336kB freed

but freezes prior to displaying the next line expected:

  INIT: version 2.85 booting

I have to reset instead at this point.

On this system the program /sbin/init is the following type:

  /sbin/init: ELF 64-bit LSB executable, IA-64, version 1 (SYSV),
  for GNU/Linux 2.4.0, dynamically linked (uses shared libs), stripped

JFReiser posted a few days ago on this lkml thread a partial analysis of
what would be required to complete this bssprot patch for ia64.

Now the job is a little bigger - not only complete the patch (required
to fix some bss protections that matter at least to Wine, but also get
it to boot again, on SN2 hardware, probably on white box ia64 hardware
as well.

This is not something I can do in a reasonable time, and I do not
have the liberty of taking an unreasonable time for this.

... seeking asistance ... who might be able to assist further here?

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373

From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 May 2003 04:59:41 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705676@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 08 May 2003 12:16:29 +1000, Keith Owens <kaos@ocs.com.au> said:

  >>  On second thought, "relinking" might be confusing.  "Relocating"
  >> is more accurate (we don't rearrange anything within the kernel,
  >> just moving the whole thing around, which is a lot easier).

  Keith> Using what data?  vmlinux does not contain any relocation
  Keith> data, everything is converted to absolute addresses in the
  Keith> the final link stage.

Oh, I would recommend to build the kernel as a shared object.  That's
what we do for EFI apps under GNU EFI and it works well.  (There are
some ugly corners in GNU EFI, but they have to do with converting the
ELF shared object into PE+ format.)

  Keith> One possibility is to link vmlinux to a temporary file, using
  Keith> -r to preserve the relocation data, followed by a link to the
  Keith> real vmlinux, without -r.  From the temporary file, extract
  Keith> the information that is required to perform boot time
  Keith> relocation and append that data to vmlinux, at _end.  The
  Keith> kernel startup code (PIC assembler) runs the additional
  Keith> table, adjusts the relocations then discards the table.

Sounds rather fragile to me.  Relocating shared objects is quite easy
actually. GNU EFI does it in 102 lines of ia64 assembly code.  That's
probably pretty hard to beat.

  Keith> A quick check of a 2.4 ia64 kernel shows only these
  Keith> relocation types:

  Keith> DIR32LSB DIR64LSB FPTR64LSB GPREL22 IMM64 LTOFF22
  Keith> LTOFF_FPTR22 PCREL21B PCREL60B SEGREL64LSB

  Keith> GPREL22, LTOFF22, LTOFF_FPTR22, PCREL21B, PCREL60B,
  Keith> SEGREL64LSB are not a problem, they are already PIC.
  Keith> DIR32LSB, DIR64LSB, FPTR64LSB are easy to adjust.  IMM64 is
  Keith> the only messy bit of code, lots of shifts.  Even IMM64 is
  Keith> not that hard to do in PIC asm.

Remember, we already have the in-kernel module loader, which has to
deal with "ld -r" modules.  I'd have preferred if those had been
shared objects, too, but apparently the toolchains on some other
platforms is sufficiently broken that this wasn't a feasible option
(not for 2.6, anyhow).

	--david


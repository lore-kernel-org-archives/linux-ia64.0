From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 08 May 2003 02:16:29 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705675@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 7 May 2003 17:23:31 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Wed, 7 May 2003 17:21:18 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:
>
>>>>>> On Wed, 7 May 2003 17:00:45 -0700, Jesse Barnes <jbarnes@sgi.com> said:
>  Jesse> Ahh, this might be a good way to go.  We'd basically be
>  Jesse> relinking the kernel at load time with a new KERNEL_START,
>  Jesse> right?
>
>  David> Yup.
>
>On second thought, "relinking" might be confusing.  "Relocating" is
>more accurate (we don't rearrange anything within the kernel, just
>moving the whole thing around, which is a lot easier).

Using what data?  vmlinux does not contain any relocation data,
everything is converted to absolute addresses in the the final link
stage.  If you only use standard ld output then elilo will have to
handle all the relocations, messy.

One possibility is to link vmlinux to a temporary file, using -r to
preserve the relocation data, followed by a link to the real vmlinux,
without -r.  From the temporary file, extract the information that is
required to perform boot time relocation and append that data to vmlinux,
at _end.  The kernel startup code (PIC assembler) runs the additional
table, adjusts the relocations then discards the table.

A quick check of a 2.4 ia64 kernel shows only these relocation types:

DIR32LSB
DIR64LSB
FPTR64LSB
GPREL22
IMM64
LTOFF22
LTOFF_FPTR22
PCREL21B
PCREL60B
SEGREL64LSB

GPREL22, LTOFF22, LTOFF_FPTR22, PCREL21B, PCREL60B, SEGREL64LSB are not
a problem, they are already PIC.  DIR32LSB, DIR64LSB, FPTR64LSB are
easy to adjust.  IMM64 is the only messy bit of code, lots of shifts.
Even IMM64 is not that hard to do in PIC asm.

This approach keeps all the kernel relocation code inside the ia64
tree, it does not rely on keeping elilo in sync with future kernel
and/or gcc changes.  By extracting and formatting the relocation data
at build time, it simplifies and speeds up the load process.



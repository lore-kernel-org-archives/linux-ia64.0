From: "Faccini, Bruno" <bruno.faccini@intel.com>
Date: Tue, 24 Oct 2000 06:39:11 +0000
Subject: RE: [Linux-ia64] Problems building "2.4.0-test9" kernel source on
Message-Id: <marc-linux-ia64-105590678205613@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205589@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205589@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ok, I installed "linux-2.4.0-test9-ia64-001004.diff.gz", downloaded from
"ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64" and as expected, due to
its content, it fixed my earlier 2 issues (multiple compilation errors for
"arch/ia64/kernel/setup.c" and "unsatisfied externals" for
"[disable,reenable]_usb()" entry points) I got with the original and full
"linux-2.4.0-test9" tar-ball.

But the patch/diff file reported a new pb/inconsistencies within the
"include/asm-ia64/offsets.h" source file :

--------
patching file linux-2.4.0-test9/include/asm-ia64/offsets.h
Hunk #1 FAILED at 11.
Hunk #2 FAILED at 21.
2 out of 2 hunks FAILED -- saving rejects to file
linux-2.4.0-test9/include/asm-ia64/offsets.h.rej
--------

and I am a little bit puzzled there due to the suspected high impact ([Task,
Thread]'s fields offsets !!) of the related values/defines (expected and new
values vs current one) :

------------
- #define IA64_TASK_SIZE			2864	/* 0xb30 */
- #define IA64_TASK_THREAD_OFFSET		896	/* 0x380 */
- #define IA64_TASK_THREAD_KSP_OFFSET	896	/* 0x380 */
- #define IA64_TASK_THREAD_SIGMASK_OFFSET	2744	/* 0xab8 */
+ #define IA64_TASK_SIZE			3328	/* 0xd00 */
+ #define IA64_TASK_THREAD_OFFSET		1424	/* 0x590 */
+ #define IA64_TASK_THREAD_KSP_OFFSET	1424	/* 0x590 */
+ #define IA64_TASK_THREAD_SIGMASK_OFFSET	3184	/* 0xc70 */

vs/with the current source lines !! :

#define IA64_TASK_SIZE			3456	/* 0xd80 */
#define IA64_TASK_THREAD_OFFSET		1456	/* 0x5b0 */
#define IA64_TASK_THREAD_KSP_OFFSET	1456	/* 0x5b0 */
#define IA64_TASK_THREAD_SIGMASK_OFFSET	3304	/* 0xce8 */
-------------

Since this "include/asm-ia64/offsets.h" file appear automatically generated
as per the "make config/make dep/make" steps
("arch/ia64/tools/print_offsets") and according to the current configuration
options, its actual content may have been computed as part of my earlier
build attempt with the "-test9" base distrib., and thus I may ignore the
current patch reported errors.

May be I am doing something wrong, but this may also point to a current
patching method lack, where config. related and generated files are included
within patches/diff files and thus prevent a safe and full install on top of
an already used Kernel build source tree.

BTW, and keeping all of this in mind, I re-ran the full Kernel clean-up and
build steps and will see how it goes (and mainly if I get a "consistent" and
coherent "arch/ia64/tools/print_offsets" file generated as part of the build
process) and let you know asap.

Bruno.

> -----Original Message-----
> From: Faccini, Bruno 
> Sent: jeudi 19 octobre 2000 13:38
> To: 'davidm@hpl.hp.com'
> Subject: RE: [Linux-ia64] Problems building "2.4.0-test9" 
> kernel source
> on/for IA-64
> 
> 
> 
> Will try it asap and let you know.
> 
> BTW, thank's for your quick reply.
> 
> Bruno.
> 
> > -----Original Message-----
> > From: David Mosberger [mailto:davidm@hpl.hp.com]
> > Sent: mercredi 18 octobre 2000 21:49
> > To: Faccini, Bruno
> > Cc: linux-ia64@linuxia64.org
> > Subject: Re: [Linux-ia64] Problems building "2.4.0-test9" 
> > kernel source
> > on/for IA-64
> > 
> > 
> > >>>>> On Tue, 17 Oct 2000 23:35:46 -0700, "Faccini, Bruno" 
> > <bruno.faccini@intel.com> said:
> > 
> >   Bruno> Trying to build "-test9" full tar-ball on/for an 
> IA-64 SDV, I
> >   Bruno> got the following problems/errors
> > 
> > Sounds like you didn't apply the IA-64 patch in the .../ports/ia64/
> > directory.  Could this be the problem?
> > 
> > 	--david
> > 
> 



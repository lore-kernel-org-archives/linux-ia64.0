From: Steve Tynor <tynor@atlanta.twr.com>
Date: Wed, 10 Jan 2001 00:58:32 +0000
Subject: Re: [Linux-ia64] ld --relax, yet still: "relocation truncated to fit: PCREL21B" or "can't relax sect
Message-Id: <marc-linux-ia64-105590678205908@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205873@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205873@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jim Wilson wrote:

| >| ./Tjdb-interp2/O.ia64-linux_n/plo_0.o: In function `func1':
| >| ./Tjdb-interp2/O.ia64-linux_n/plo_0.o(.text+0x1046862): relocation truncated to fit: PCREL21B func2
| >| ...
| >| collect2: ld returned 1 exit status
| 
| Do you have a testcase I can look at?  As far as I know, --relax still works.
| 
| This problem happens when you are calling a function that is too far away
| for the offset in a br.call instruction.  Or jumping to a branch that is too
| far away.  This could be a toolchain bug, or it could be a problem with the
| program.

Aha! That explains it.  It turns out that the .o files causing the
problem are quite large (the result of linking a bunch of smaller ones
together with "ld -r ...".  By avoiding this and linking the smaller
.o's directly into the executable, I can work around the bug.

| 
| >| /usr/bin/ld: can't relax section: No such file or directory
| >| collect2: ld returned 1 exit status
| 
| This was a temporary problem.  It occurs if you have a toolchain with Richard
| Henderson's 2000-10-09 bfd patch for sorting unwind sections, but don't have
| his 2000-10-24 bfd patch which makes it work.  I never released a toolchain
| with the first patch but not the second.  Perhaps you got a toolchain from
| someone else?  Or maybe you applied random patches from some mailing list
| to your toolchain?

The 2.9 toolchain is stock as it came with TurboLinux 0825.  

The 2.96 toolchain was from your gcc-092500 snapshot with the glibc2.1.3
patch, "patch.022" and a gas and gcc patch that you sent me in email to
address a WAW/WAR dependency I reported a while back.

| 
| >        gcc version 2.96-ia64-000717 snap 000925
| >	GNU ld version 2.9-ia64-000717 (with BFD 2.9-ia64-000717))
| 
| This is 2 months obsolete.  The 001117 snapshot should be used instead of this
| one.

When our hardware is upgraded, we plan to move to newer kernels, newer
glibc's, and (I'm sure!) improved toolchains...

Thanks,
Steve


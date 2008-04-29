From: "stephane eranian" <eranian@googlemail.com>
Date: Tue, 29 Apr 2008 21:47:17 +0000
Subject: 2.6.25 new perfmon kernel patch + libpfm + pfmon available
Message-Id: <7c86c4470804291447w713934a7o2b8a5a690fc9a535@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470804291446l4693b317ha7ee2382d00e99e6@mail.gmail.com>
In-Reply-To: <7c86c4470804291446l4693b317ha7ee2382d00e99e6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: ia64 <linux-ia64@vger.kernel.org>

Hello,

 I have released the perfmon2 kernel patch for kernel v2.6.25. There is
 no major features. However, there were a major restructuring of the code
 to make it more readable, isolate features per module. The header files
 have also been restructured to separate user vs. kernel, and generic only
 vs. shared with arch. The restructuring of the interrupt handler yielded
 a nice 15% latency improvement on single counter sampling runs on X86.
 This new structure will make it easier to extract features and merge them
 with the mainline kernel.

 In the time frame of 2.6.26, I will push a few bits and pieces to LKML
 for final review and integration.

 Here are some of the kernel changes:
  - Cell updates (Carl Love, Takashi Yamamoto)
  - new perfmon_debug boot option to enable debug (Robert Richter)
  - several bugs fixes on Itanium, MIPS and generic hrtimer management
  - Power locking updates (Corey Ashford)

 There is also a new release for libpfm, now at version 3.4.
 The changes include:
  - AMD Phenom (a.k.a. Barcelona) IBS support (Robert Richter)
  - Python bindings and examples (Arun Sharma)
  - environment variable support to enable debugging
  - auto-detection of syscall base number for 2.6.24 and 2.6.25
  - new multi-threaded self-sampling example (Mark W. Krentel)
  - man pages cleanups (Steve Kaufmann)

 Special thanks to Arun (Google). The Python bindings are a nice addition
 to libpfm especially for prototyping and writing testsuites.

 Finally, a new major version of pfmon, now at pfmon-3.4.
 Among the many changes:
  - added support for dmalloc (Andrzej Nowak)
  - updated support for Cell processor (Takashi Yamamoto)
  - possibility to terminate pfmon cleanly with SIGTERM
  - --follow-fork and derivatives fixed on Itanium and other platforms
  - tracking of dlopen now works on mixed ABI environments
  - lots of bugs fixes

 As usual all files and more detailed changelogs can be downloaded from our
 website at:

        http://perfmon.sourceforge.net

 Enjoy,

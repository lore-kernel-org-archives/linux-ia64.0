From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 22 Mar 2001 22:18:15 +0000
Subject: Re: [Linux-ia64] kernel update (second patch relative to 2.4.2)
Message-Id: <marc-linux-ia64-105590693005340@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>	o Modified the exception table format to take advantage of
>	  local tags if they're support.  To take full advantage of
>	  this, a gcc3.0 based toolchain would be necessary.  However,

Actually, this is a binutils feature.  The version of gcc that you have is
irrelevant.  This might matter because not everybody uses the same binutils
version with the same gcc version.  You need a binutils from last week or
newer.  This patch will be in binutils 2.11.

>  However,
>	  the prerelease version of this compiler is NOT yet stable
>	  enough for kernel use.  So even though you find a bunch of
>	  "#if __GNUC__ >= 3" in the patch, I do not recommend
>	  building with this compiler at this time.

Is there a particular reason why we can't use gcc3 yet?  I know that there
is a problem with unwind info when a particular optimization occurs, however,
the exact same bug is present in the compiler that everyone is already using.
The only difference is that -freorder-blocks is the default with the current
compiler, but was not the default when I branched the stable compiler.
Thus if this is the only problem, then the kernel will work fine if you use
-fno-reorder-blocks.  This problem is on my short list, I have a patch
that fixes the unwind info, but I also need to write a patch to fix the
C++ EH unwinder.

Jim


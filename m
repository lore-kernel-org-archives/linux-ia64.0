From: Alan Modra <amodra@bigpond.net.au>
Date: Fri, 04 Jan 2002 12:02:51 +0000
Subject: [Linux-ia64] Re: Compiling kernel 2.4.17 fails at link stage
Message-Id: <marc-linux-ia64-105590698805740@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 31, 2001 at 08:56:38PM -0600, Krishnakumar B wrote:
> 
> I am trying to compile kernel 2.4.17 (with davidm's patches
> linux-2.4.17-ia64-011226) using gcc-3.0.3 and binutils 2.11.92.0.12.3
> 20011121. I get the following error at final kernel link stage:
[snip]
> arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x0): undefined reference to `local symbols in discarded section .text.exit'

It's a kernel bug exposed by recent binutils.  You can either fix the
kernel by making the references weak, or hack around the problem by
adding -fnoinhibit-exec to the ld command line.

Alan



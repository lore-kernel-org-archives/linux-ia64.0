From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 16 Apr 2003 23:16:45 +0000
Subject: [Linux-ia64] Re: asm-ia64/fpu.h portability improvement
Message-Id: <marc-linux-ia64-105590723705521@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 27 March 2003 6:11 pm, David Mosberger wrote:
> The patch below makes the declaration of "struct ia64_fpreg" portable
> accross compilers.  Bjorn, I think it would be good to make the same
> change in 2.4.xx.
> 
> Even though it's a change to a kernel header file, this patch is
> intended to fix a bug in glibc: without this patch, using a compiler
> other than gcc will lead to a sigcontext/ucontext type which isn't
> properly aligned.

I applied this for 2.4 (so it will be in the 2.4.21 ia64 patch).


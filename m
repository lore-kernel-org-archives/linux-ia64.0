From: Gary Hade <garyhade@us.ibm.com>
Date: Mon, 08 Apr 2002 16:00:42 +0000
Subject: Re: [Linux-ia64] C++ doesn't like asm/atomic.h
Message-Id: <marc-linux-ia64-105590701905407@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905396@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905396@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 05, 2002 at 01:54:27PM -0800, David Mosberger wrote:
> >>>>> On Fri, 5 Apr 2002 13:40:34 -0800, Gary Hade <garyhade@us.ibm.com> said:
> 
>   Gary> asm/atomic.h is not palatable to C++ due to it's use of the
>   Gary> C++ keyword "new".
> 
> Eh, the kernel is written in C.  If you have an application that
> includes a kernel header, fix the application---it's broken.  (This
> has been Linus' edict for the last N years, for some N > 3...)
> 
> 	--david

Oops, I must admit that my gray matter is definitely corrupted by 
working on systems where there was an effort to use #ifdef __KERNEL__ 
to keep all kernel-only code from being included in user-level 
application code.

Would it be okay in the Linux world for an application written 
in C++ to use a system call such as query_module(2)?  If so, the 
application code would include <linux/module.h>.  <linux/module.h>
includes <asm/atomic.h> on a line which is not within an 
#ifdef __KERNEL__ region so the same C++ compile failure will occur.

Gary


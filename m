From: Don Dugger <n0ano@valinux.com>
Date: Fri, 16 Mar 2001 16:39:30 +0000
Subject: Re: [Linux-ia64] Possible bug in getname32
Message-Id: <marc-linux-ia64-105590693005285@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005284@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005284@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dave-

Thanks for the report.  The simple answer is no, this is not a problem
on IA64.

The more detailed answer is we don't use that code.  If you look up
from `getname32' a little you'll discover that this code is inside
a `#ifdef NOTYET' block and is not compiled into the kernel.  When we
started the IA32 support we used, I believe, `sparc64' code as a
template but ifdef'd out most of the code.  As we discovered system
calls that needed to be translated we pulled the code out of the
ifdef area and made sure it worked properly.  (Because of the way
IA64 passes system call parameters many system calls that would need
to be translated on other architectures don't need to be modified
on IA64 and I didn't want to needlessly translate things that `just
work').  The `getname32' code hasn't been needed yet (and probably 
never will be now that you've pointed out a bug with it :-)

On Fri, Mar 16, 2001 at 10:04:23AM -0600, David Engebretsen wrote:
> Although I do not work on linux-ia64, I believe we found a bug bringing up
> PPC64 that also exists in the IA64 code that someone might want to look
> into.
> 
> In arch/ia64/ia32/sys_ia32.c, the function getname32 allocates storage via
> __get_free_page and then returns it via putname (aka kmem_cache_free).
> This mismatch of storage allocation schemes can cause all kinds of subtle
> problems as we found in PPC64.
> 
> Is this a legitimate bug, or are we missing something here?
> 
> Thanks -
> 
> Dave Engebretsen
> Linux on PowerPC Development, IBM Rochester
> Internal  : ibmusm07(engebret), T/L 8-553-2925
> External : engebret@us.ibm.com, (507) 253-2925
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838


From: n0ano@indstorage.com
Date: Wed, 05 Dec 2001 21:37:58 +0000
Subject: Re: [Linux-ia64] mprotect??
Message-Id: <marc-linux-ia64-105590698805628@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805626@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805626@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

D'Laila-

We need a lot more detail than this.  In general, yes, mprotect works.
This system call is used extensively by the shared library loader.

Are you running an IA32 or IA64 program?  The output of an `strace'
from one of your failing runs would be helpful.

On Wed, Dec 05, 2001 at 03:09:40PM -0600, D'laila Pereira wrote:
> Hi
> I am running a program on Linux (tried on both TurboLinux, and Redhat
> linux) ,itanium machine , that needs to "mprotect" (PROT_READ or
> PROT_RD/WR, depending on the certain parameters) a sequence of pages. What
> i noticed is that "mprotect" works at times, but does not take affect at
> other times. What is the cause of such random behaviur of mprotect.?
> Does mprotect work for Linux Itanium, or there is some problem with it ?
> 
> thanks
> d'laila
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117


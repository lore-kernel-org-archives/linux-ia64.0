From: n0ano@indstorage.com
Date: Mon, 03 Jun 2002 15:00:01 +0000
Subject: Re: [Linux-ia64] Integer to Pointer Cast Warnings when Building 2.4.17
Message-Id: <marc-linux-ia64-105590701905631@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905629@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905629@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Arun-

Looks like the prototype for `__do_clear_user' changed, I can fix this
when I get home this evening.

On Mon, Jun 03, 2002 at 05:57:47PM +0530, LAKSHMIPATHY,ARUN (HP-India,ex2) wrote:
> Hi,
> 
> I Get an integer to pointer typecast warning from some of the sources when
> building the 2.4.17 kernel, I am using the base 2.4.17 kernel and the ia64
> patch with no other patches, the kernel builds fine and comes up fine.
> Wanted to be sure that this is not a cause for concern. Enclosed below is
> the excerpt of the build o/p.
> 
> make[1]: Entering directory `/kernel/linux/arch/ia64/ia32'
> sys_ia32.c: In function `sys32_brk':
> sys_ia32.c:3824: warning: passing arg 1 of `__do_clear_user' makes pointer
> from integer without a cast
> 

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117


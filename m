From: Gary Hade <garyhade@us.ibm.com>
Date: Fri, 15 Mar 2002 22:44:36 +0000
Subject: Re: [Linux-ia64] Re: compiler version for kernel builds
Message-Id: <marc-linux-ia64-105590701905299@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905292@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905292@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 14, 2002 at 07:56:07PM -0800, David Mosberger wrote:
> >>>>> On Thu, 14 Mar 2002 15:46:04 -0800, Jesse Barnes <jbarnes@sgi.com> said:
> 
>   Jesse> David, which compiler version do you use for kernel builds
>   Jesse> these days?
> 
> I usually use 3.0, though I try to remember to test with 2.96 from
> time to time.  I haven't had much luck with 3.1 yet: it builds a
> working kernel for the simulator, but the kernel for the real machine
> dies early on.  Haven't had time yet to investigate.

I can confirm that gcc-3_1-branch (as of yesterday) is still 
unable to build a working kernel.

A few days ago the most current 3.1 source wouldn't even compile 
the 2.4.17 kernel source.  It was dying with an internal compiler 
error while attempting to compile linux/fs/jbd/journal.c.  I 
submitted GCC PR 5892 which was fixed on 3/13. 

Using a gcc built yesterday from the gcc-3_1-branch containing 
the above fix I hit a link-time error due to an unresolved reference 
to __xchg_called_with_bad_pointer.  We determined that this problem 
was due to a change in the compiler inlining behavior where 
static inline functions over a certain size are no longer being 
inlined by default.  It appears that we will need to use 
-finline-limit=n to force inlining of larger functions.  After 
adding -finline-limit 00 the kernel compiles and links.  
Unfortunately, it hangs right away when you try to boot it.

I'll let you if we learn more.

Gary

> 
>   Jesse> Also, is there a document somewhere that
>   Jesse> describes building that version as a cross compiler?  Last
>   Jesse> time I tried building 3.0.2 as an x86 hosted ia64 cross
>   Jesse> compiler, I ran into some trouble.
> 
> We posted something on this list a while ago (search for "recipe" or
> something like that).  We haven't built a cross-compiler recently, so
> the recipe may not be perfectly accurate anymore.
> 
> 	--david
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Gary Hade
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc


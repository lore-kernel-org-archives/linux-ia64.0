From: Don Dugger <n0ano@valinux.com>
Date: Wed, 02 May 2001 19:37:27 +0000
Subject: Re: [Linux-ia64] Possible bug in siginfo64to32()
Message-Id: <marc-linux-ia64-105590693005517@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005514@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005514@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dave-

Certainly looks like a bug to me.  Makes you wonder how the code ever
worked.

Thanks for spotting it.

On Wed, May 02, 2001 at 02:29:01PM -0500, David Engebretsen wrote:
> Although I do not work on linux-ia64, I believe we found a bug bringing up
> PPC64 with some regression tests that also exists in the IA64 code that
> someone might want to look into.
> 
> In arch/ia64/ia32/sys_ia32.c, the function siginfo64to32(siginfo_t32 *d,
> ...)
> does the following:
>    memset(&d, 0, sizeof(siginfo_t32));
> 
> Seems like the &d should just be d.
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


From: n0ano@indstorage.com
Date: Mon, 22 Apr 2002 14:47:53 +0000
Subject: Re: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905488@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yoav-

Simple answer: Yes, it can be safely removed.

Longer answer:  David likes to use `gdb' to track down bugs, it makes life
easier to take a fault address and use `gdb' to find the exact source line
that caused the error.  I personally don't like the size of the boot image
file that this creates so one of the first things I've always done after
applying all of the IA64 patches is remove this flag.  Use it or not,
whatever you prefer.

On Mon, Apr 22, 2002 at 10:02:52AM +0300, Zach, Yoav wrote:
> The latest patch adds the '-g' switch to the main Makefile. When doing
> 'make', the size of the resulted binary is ~55M. Without the '-g', its size
> is ~8M. Was this switch added as a workaround for some problem, or can it be
> removed safely ?
> 
> Thanks,
> Yoav.
> 
> -----Original Message-----
> From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
> Sent: Thursday, April 11, 2002 0:42 AM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] new kernel patch (relative to 2.4.18)
> 
> 
> The latest ia64 patch relative to 2.4.18 is now available
> at ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/
> in file:
> 
> 	linux-2.4.18-ia64-020410.diff.gz
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


From: Don Dugger <n0ano@valinux.com>
Date: Mon, 16 Apr 2001 20:16:20 +0000
Subject: Re: [Linux-ia64] Page size
Message-Id: <marc-linux-ia64-105590693005410@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005409@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005409@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mike-

You are correct, page size is a compile time constant, you cannot change
it at run time.

The `getpagesize' GLIBC function returns the kernel's page size.

On Mon, Apr 16, 2001 at 12:50:13PM -0700, Michael Madore wrote:
> Someone asked me the followind two questions, and I wanted to verify before
> I gave an answer:
> 
> Is page size tunable at run time, and can the page size be determined at run
> time.
> 
> I was under the impression that page size was a build time parameter.
> 
> -- 
> Mike Madore
> Software Engineer
> TurboLinux, Inc.
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


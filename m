From: Francis Galiegue <fg@mandrakesoft.com>
Date: Thu, 16 Nov 2000 18:05:15 +0000
Subject: Re: [Linux-ia64] gcc: thanks
Message-Id: <marc-linux-ia64-105590678205733@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205731@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205731@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 16 Nov 2000, H . J . Lu wrote:

> 
> I have 2 patches to fix an ABI bug in binutils and glibc where the
> DT_INIT/FINI entries should be the function address, not the function
> descriptor. As of today, binutils and glibc assume they are function
> addresses. My patches are at
> 
> http://ftp.valinux.com/pub/support/hjl/ia64/bfd-init.patch
> http://ftp.valinux.com/pub/support/hjl/ia64/glibc-2.2-init.patch
> 
> They should be tested and checked in ASAP.
> 

Downloaded, will test tomorrow. Thanks.

-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook



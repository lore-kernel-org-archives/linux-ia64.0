From: Francis Galiegue <fg@mandrakesoft.com>
Date: Fri, 10 Nov 2000 14:49:43 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test10
Message-Id: <marc-linux-ia64-105590678205682@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 10 Nov 2000, Jes Sorensen wrote:

> Francis> Right now I'm using the ia64-final version of gcc, and from
> Francis> test10 on a check is done on whether __GNUC_MINOR__ is
> Francis> greater than 91. ia64-final returns 9 which is obviously not
> Francis> what the kernel expects...
> 
> Which compiler is this?
> 

2.9-ia64-000216-final

> Francis> After commenting this out and fixing by hand quite a lot of
> Francis> places, I got it to compile and boot though. But more recent
> Francis> snapshots of gcc are available. Are they worth upgrading?
> 
> Yes, you need the latest to compile glibc anyway.
> 

OK, thanks :)


-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook



From: Jes Sorensen <jes@linuxcare.com>
Date: Fri, 10 Nov 2000 14:17:14 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test10 and upper?
Message-Id: <marc-linux-ia64-105590678205681@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Francis" = Francis Galiegue <fg@mandrakesoft.com> writes:

Francis> Right now I'm using the ia64-final version of gcc, and from
Francis> test10 on a check is done on whether __GNUC_MINOR__ is
Francis> greater than 91. ia64-final returns 9 which is obviously not
Francis> what the kernel expects...

Which compiler is this?

Francis> After commenting this out and fixing by hand quite a lot of
Francis> places, I got it to compile and boot though. But more recent
Francis> snapshots of gcc are available. Are they worth upgrading?

Yes, you need the latest to compile glibc anyway.

Francis> Also, will the current glibc-2.2 compile as is on ia64 and
Francis> work?

Yes

Jes


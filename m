From: Jes Sorensen <jes@linuxcare.com>
Date: Thu, 23 Nov 2000 18:57:42 +0000
Subject: Re: [Linux-ia64] -ma-step and -mconstant-gp options for gcc?
Message-Id: <marc-linux-ia64-105590678205771@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205770@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205770@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Francis" = Francis Galiegue <fg@mandrakesoft.com> writes:

Francis> I wonder what the two options in $subject do...  For
Francis> -ma-step, I can guess this assumes that the code will run on
Francis> an A stepping CPU, but in this case, will it run on a B? If I
Francis> want to compile a kernel for a B stepping processor, I guess
Francis> I have to remove this option?

The first one enables workarounds in the compiler so it doesn't
generate code that triggers problems on the A-step's.

The second tells the compiler that the gp is constant so it doesn't
constantly reload it when calling functions. It's used by the kernel.

Jes


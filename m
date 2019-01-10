From: Joseph Myers <joseph@codesourcery.com>
Date: Thu, 10 Jan 2019 18:10:05 +0000
Subject: Re: [PATCH 00/15] arch: synchronize syscall tables in preparation for y2038
Message-Id: <alpine.DEB.2.21.1901101808220.31458@digraph.polyomino.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190110162435.309262-1-arnd@arndb.de>
In-Reply-To: <20190110162435.309262-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, catalin.marinas@arm.com, heiko.carstens@de.ibm.com, linux@dominikbrodowski.net, linux-mips@vger.kernel.org, jcmvbkbc@gmail.com, deepa.kernel@gmail.com, hpa@zytor.com, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, dave@stgolabs.net, y2038@lists.linaro.org, mpe@ellerman.id.au, deller@gmx.de, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, geert@linux-m68k.org, firoz.khan@linaro.org, mattst88@gmail.com, fenghua.yu@intel.com, will.deacon@arm.com, linux-m68k@lists.linux-m68k.org, ink@jurassic.park.msu.ru, luto@kernel.org, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, monstr@monstr.eu, tony.luck@intel.com, linux-parisc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, paul.burton@mips.com, ebiederm@xmission.com, linux-alpha@vger.kernel.org, schwidefsky@de

On Thu, 10 Jan 2019, Arnd Bergmann wrote:

> - Add system calls that have not yet been integrated into all
>   architectures but that we definitely want there.

glibc has a note that alpha lacks statfs64, any plans for that?

-- 
Joseph S. Myers
joseph@codesourcery.com

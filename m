From: Gabriel Paubert <paubert@iram.es>
Date: Fri, 18 Jan 2019 17:18:30 +0000
Subject: Re: [PATCH v2 13/29] arch: add split IPC system calls where needed
Message-Id: <20190118171830.quvvwdgbuhq2nqrh@lt-gp.iram.es>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190118161835.2259170-1-arnd@arndb.de>
 <20190118161835.2259170-14-arnd@arndb.de>
In-Reply-To: <20190118161835.2259170-14-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, linux-mips@vger.kernel.org, jcmvbkbc@gmail.com, deepa.kernel@gmail.com, hpa@zytor.com, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, y2038@lists.linaro.org, deller@gmx.de, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, geert@linux-m68k.org, firoz.khan@linaro.org, mattst88@gmail.com, fenghua.yu@intel.com, heiko.carstens@de.ibm.com, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, linux-m68k@lists.linux-m68k.org, luto@kernel.org, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, monstr@monstr.eu, tony.luck@intel.com, linux-parisc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, paul.burton@mips.com, ebiederm@xmission.com, netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Fri, Jan 18, 2019 at 05:18:19PM +0100, Arnd Bergmann wrote:
> The IPC system call handling is highly inconsistent across architectures,
> some use sys_ipc, some use separate calls, and some use both.  We also
> have some architectures that require passing IPC_64 in the flags, and
> others that set it implicitly.
> 
> For the additon of a y2083 safe semtimedop() system call, I chose to only

It's not critical, but there are two typos in that line: 
additon -> addition
2083 -> 2038

	Gabriel

> support the separate entry points, but that requires first supporting
> the regular ones with their own syscall numbers.
> 
> The IPC_64 is now implied by the new semctl/shmctl/msgctl system
> calls even on the architectures that require passing it with the ipc()
> multiplexer.
> 
> I'm not adding the new semtimedop() or semop() on 32-bit architectures,
> those will get implemented using the new semtimedop_time64() version
> that gets added along with the other time64 calls.
> Three 64-bit architectures (powerpc, s390 and sparc) get semtimedop().
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

From: Catalin Marinas <catalin.marinas@arm.com>
Date: Sun, 15 May 2022 10:03:13 +0000
Subject: Re: [PATCHv4 2/2] cpu/hotplug: Remove the input parameter primary_cpu of smp_shutdown_nonboot_cpus()
Message-Id: <YoDP4aYg7vdUg4sO@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220512030619.13426-1-kernelfans@gmail.com>
 <20220512030619.13426-3-kernelfans@gmail.com>
In-Reply-To: <20220512030619.13426-3-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-ia64@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Thomas Gleixner <tglx@linutronix.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Jens Axboe <axboe@kernel.dk>, Russell King <linux@armlinux.org.uk>, Guenter Roeck <linux@roeck-us.net>, Arnd Bergmann <arnd@arndb.de>, Wolfram Sang <wsa+renesas@sang-engineering.com>, Lee Jones <lee.jones@linaro.org>, Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Peter Collingbourne <pcc@google.com>, Marc Zyngier <maz@kernel.org>, linux-kernel@vger.kernel.org

On Thu, May 12, 2022 at 11:06:19AM +0800, Pingfan Liu wrote:
> For all call sites of smp_shutdown_nonboot_cpus(),
> 
> $git grep smp_shutdown_nonboot_cpus -- arch | grep -v \*
> arch/arm/kernel/reboot.c:94:    smp_shutdown_nonboot_cpus(reboot_cpu);
> arch/arm64/kernel/process.c:89: smp_shutdown_nonboot_cpus(reboot_cpu);
> arch/ia64/kernel/process.c:578: smp_shutdown_nonboot_cpus(reboot_cpu);
> arch/riscv/kernel/machine_kexec.c:135:  smp_shutdown_nonboot_cpus(smp_processor_id());
> 
> As it shows, the input parameter seems a little arbitrary.
> 
> Since kernel_kexec()->migrate_to_reboot_cpu() has already pinned the
> rebooting thread on the selected CPU and the CPU hotplug keeps disabled
> before smp_shutdown_nonboot_cpus(). Let smp_shutdown_nonboot_cpus()
> deduce the rebooting CPU by smp_processor_id(), instead of passing the
> parameter primary_cpu to it.
> 
> As a result, all call sites look consistent.
> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> To: linux-ia64@vger.kernel.org
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Guenter Roeck <linux@roeck-us.net>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Wolfram Sang <wsa+renesas@sang-engineering.com>
> Cc: Lee Jones <lee.jones@linaro.org>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will@kernel.org>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Peter Collingbourne <pcc@google.com>
> Cc: Marc Zyngier <maz@kernel.org>
> To: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org

For arm64:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

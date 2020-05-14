From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Thu, 14 May 2020 10:21:13 +0000
Subject: Re: [PATCH] ia64: enable HAVE_COPY_THREAD_TLS, switch to kernel_clone_args
Message-Id: <4aad9ad5-b0e9-12b0-0ad2-ac23fceae87b@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200513204848.1208864-1-christian.brauner@ubuntu.com>
 <3908561D78D1C84285E8C5FCA982C28F7F6266E0@ORSMSX115.amr.corp.intel.com>
 <79e58d9b-5a39-390c-2f0c-0d87b63442b4@physik.fu-berlin.de>
 <20200514074606.vkc35syhdep23rzh@wittgenstein>
 <6b298416-1e64-eee7-0bb4-3b1f7f67adc6@physik.fu-berlin.de>
 <d6c94d4f-a431-9de5-7a0f-661894dbec01@physik.fu-berlin.de>
 <20200514100459.pt7dxq2faghdds2c@wittgenstein>
 <2e22b0d2-b9ce-420d-48a0-0d9134108a5c@physik.fu-berlin.de>
 <20200514101540.25hvle74w63t66fs@wittgenstein>
 <20200514101914.fu7xhgaxtb5fy2ky@wittgenstein>
In-Reply-To: <20200514101914.fu7xhgaxtb5fy2ky@wittgenstein>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Qais Yousef <qais.yousef@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 5/14/20 12:19 PM, Christian Brauner wrote:
> Scratch that. It's even worse. On ia64 it is _invalid_ to pass a NULL
> stack. That's at least what the glibc assembly assumes:
> 
> 	cmp.eq p6,p0=0,in0
> 	cmp.eq p7,p0=0,in1
> 	mov r8=EINVAL
> 	mov out0=in3		/* Flags are first syscall argument.	*/
> 	mov out1=in1		/* Stack address.			*/
> (p6)	br.cond.spnt.many __syscall_error	/* no NULL function pointers */
> (p7)	br.cond.spnt.many __syscall_error	/* no NULL stack pointers */
> 	;;
> 	mov out2=in2		/* Stack size.				*/
> 
> so newer systemd just works by accident on ia64 if at all correctly
> afaict.

Hmm, interesting. I really wasn't aware of that. Thanks for the heads-up.

I'll ask Michael whether he can come up for a solution for that problem.

Maybe that's also why systemd crashes.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913

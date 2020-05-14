From: Andreas Schwab <schwab@linux-m68k.org>
Date: Thu, 14 May 2020 10:45:41 +0000
Subject: Re: [PATCH] ia64: enable HAVE_COPY_THREAD_TLS, switch to kernel_clone_args
Message-Id: <877dxe6bhm.fsf@igel.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <3908561D78D1C84285E8C5FCA982C28F7F6266E0@ORSMSX115.amr.corp.intel.com>
        <79e58d9b-5a39-390c-2f0c-0d87b63442b4@physik.fu-berlin.de>
        <20200514074606.vkc35syhdep23rzh@wittgenstein>
        <6b298416-1e64-eee7-0bb4-3b1f7f67adc6@physik.fu-berlin.de>
        <d6c94d4f-a431-9de5-7a0f-661894dbec01@physik.fu-berlin.de>
        <20200514100459.pt7dxq2faghdds2c@wittgenstein>
        <2e22b0d2-b9ce-420d-48a0-0d9134108a5c@physik.fu-berlin.de>
        <20200514101540.25hvle74w63t66fs@wittgenstein>
        <20200514101914.fu7xhgaxtb5fy2ky@wittgenstein>
        <4aad9ad5-b0e9-12b0-0ad2-ac23fceae87b@physik.fu-berlin.de>
        <20200514103259.tdfjc5ds4igpmoxj@wittgenstein>
In-Reply-To: <20200514103259.tdfjc5ds4igpmoxj@wittgenstein> (Christian
        Brauner's message of "Thu, 14 May 2020 12:32:59 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Qais Yousef <qais.yousef@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mai 14 2020, Christian Brauner wrote:

>         pid = syscall(189 /* __NR_clone2 */, SIGCHLD, stack, STACK_SIZE, NULL, NULL);

Syscall 189 doesn't exist on ia64, they start with 1024 (and __NR_clone2
is 1213).

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 7578 EB47 D4E5 4D69 2510  2552 DF73 E780 A9DA AEC1
"And now for something completely different."

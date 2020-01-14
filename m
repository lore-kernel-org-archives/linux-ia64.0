From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 14 Jan 2020 16:19:59 +0000
Subject: Re: [PATCH RESEND v4] reboot: support offline CPUs before reboot
Message-Id: <87o8v6au34.fsf@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200114110620.164861-1-hsinyi@chromium.org>
In-Reply-To: <20200114110620.164861-1-hsinyi@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hsin-Yi Wang <hsinyi@chromium.org>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, Guenter Roeck <groeck@chromium.org>, Will Deacon <will@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-s390@vger.kernel.org, linux-csky@vger.kernel.org, Aaro Koskinen <aaro.koskinen@nokia.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-pm@vger.kernel.org, linux-xtensa@linux-xtensa.org, Stephen Boyd <swboyd@chromium.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Pavankumar Kondeti <pkondeti@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, James Morse <james.morse@arm.com>, Jiri Kosina <jkosina@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, linuxppc-dev@lists.ozlabs.org

Hsin-Yi Wang <hsinyi@chromium.org> writes:
>
> Signed-off-by: Hsin-Yi Wang <hsinyi@chromium.org>
> ---
> Resend v4:
> * Cc more people and mailing lists. Also fix a few nits from v4.

Please don't name it resend if you actually changed the patch. Resend
wants to be an unmodified patch and the only reasons to do that are:

 - add more people to CC

 - Resend it because it got ignored or dropped (do that only after a
   couple of weeks)

If you changed the patch, then it wants a new version number.

Thanks,

        tglx

From: Keith Owens <kaos@sgi.com>
Date: Wed, 25 Jan 2006 06:27:18 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <19510.1138170438@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brent Casavant (on Tue, 24 Jan 2006 15:12:48 -0600 (CST)) wrote:
>+void sn_switch_from(struct task_struct *task)
>+{
>+	pda_t *last_pda = pdacpu(task_thread_info(task)->last_cpu);
>+	volatile unsigned long *adr = last_pda->pio_write_status_addr;
>+	unsigned long val = last_pda->pio_write_status_val;
>+
>+	/* Drain PIO writes from old CPU's Shub */
>+	while ((*adr & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK) != val)
>+		cpu_relax();
>+}

cpu_relax() maps to ia64_hint(ia64_hint_pause) which is defined as a
memory clobber, so you do not need to mark adr as volatile.  Linus
recommends against relying on volatile in C code, memory barrier
operations like cpu_relax should be used instead.

Alas include/asm-ia64/intel_intrin.h defines ia64_hint() as a no-op.
That needs to be fixed.


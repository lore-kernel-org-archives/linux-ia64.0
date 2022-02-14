From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 14 Feb 2022 12:24:03 +0000
Subject: Re: [PATCH 7/8] kernel/fork: Only cache the VMAP stack in finish_task_switch().
Message-Id: <YgpJ41q35k+KCsk4@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220125152652.1963111-1-bigeasy@linutronix.de>
 <20220125152652.1963111-8-bigeasy@linutronix.de>
 <00f9c7a6-2d1d-f871-e9bc-00e2217f40f9@kernel.org>
 <YgpGnFlTS+2Ugfw4@linutronix.de>
In-Reply-To: <YgpGnFlTS+2Ugfw4@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>

On 2022-02-14 13:10:06 [+0100], To Andy Lutomirski wrote:
> 
> I think I could use the first few bytes of the stack as a RCU-head. Let
> me try that.

task::stack_vm_area and ::stack. Now I remember why I went for that bit.
But I do have (hopefully) a better idea now.

> > --Andy

Sebastian

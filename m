From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 17 Jan 2002 08:06:51 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805869@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 17 Jan 2002 10:43:21 +0100 (CET), Ingo Molnar <mingo@elte.hu> said:

  Ingo> Every architecture has to define the following function:

  Ingo>      extern void smp_migrate_task(int cpu, task_t *task);

  Ingo> the lowlevel code has to pass the 'task' pointer over to the
  Ingo> target CPU.  (architectures that can send information in
  Ingo> cross-CPU messages can send it over directly - in the x86 case
  Ingo> it's done similarly to smp_call_function().)

That sounds much better.

Thanks,

	--david


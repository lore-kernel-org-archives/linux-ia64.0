From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 17 Jan 2002 09:43:21 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805866@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 16 Jan 2002, David Mosberger wrote:

> The fundamental problem is that current set_cpus_allowed() lets the
> same task run on two CPUs for a brief period of time.  This violates
> scheduling assumptions made by the kernel and hence results in race
> conditions.

i've fixed this in -J0 already, without adding overhead to the scheduler
hotpath. I've added better task-migration code as well. Every architecture
has to define the following function:

     extern void smp_migrate_task(int cpu, task_t *task);

the lowlevel code has to pass the 'task' pointer over to the target CPU.
(architectures that can send information in cross-CPU messages can send it
over directly - in the x86 case it's done similarly to
smp_call_function().)

	Ingo



From: Yann Droneaud <ydroneaud@opteya.com>
Date: Wed, 15 May 2019 14:00:20 +0000
Subject: Re: [PATCH 1/2] pid: add pidfd_open()
Message-Id: <4c5ae46657e1931a832def5645db61eb0bf1accd.camel@opteya.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190515100400.3450-1-christian@brauner.io>
In-Reply-To: <20190515100400.3450-1-christian@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christian Brauner <christian@brauner.io>, jannh@google.com, oleg@redhat.com, viro@zeniv.linux.org.uk, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, arnd@arndb.de, dhowells@redhat.com
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-mips@vger.kernel.org, linux-kselftest@vger.kernel.org, sparclinux@vger.kernel.org, elena.reshetova@intel.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-xtensa@linux-xtensa.org, keescook@chromium.org, linux-m68k@lists.linux-m68k.org, luto@kernel.org, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, linux-api@vger.kernel.org, cyphar@cyphar.com, luto@amacapital.net, ebiederm@xmission.com, linux-alpha@vger.kernel.org, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org

Hi,

Le mercredi 15 mai 2019 à 12:03 +0200, Christian Brauner a écrit :
> 
> diff --git a/kernel/pid.c b/kernel/pid.c
> index 20881598bdfa..237d18d6ecb8 100644
> --- a/kernel/pid.c
> +++ b/kernel/pid.c
> @@ -451,6 +452,53 @@ struct pid *find_ge_pid(int nr, struct
> pid_namespace *ns)
>  	return idr_get_next(&ns->idr, &nr);
>  }
>  
> +/**
> + * pidfd_open() - Open new pid file descriptor.
> + *
> + * @pid:   pid for which to retrieve a pidfd
> + * @flags: flags to pass
> + *
> + * This creates a new pid file descriptor with the O_CLOEXEC flag set for
> + * the process identified by @pid. Currently, the process identified by
> + * @pid must be a thread-group leader. This restriction currently exists
> + * for all aspects of pidfds including pidfd creation (CLONE_PIDFD cannot
> + * be used with CLONE_THREAD) and pidfd polling (only supports thread group
> + * leaders).
> + *

Would it be possible to create file descriptor with "restricted"
operation ?

- O_RDONLY: waiting for process completion allowed (for example)
- O_WRONLY: sending process signal allowed

For example, a process could send over a Unix socket a process a pidfd,
allowing this to only wait for completion, but not sending signal ?

I see the permission check is not done in pidfd_open(), so what prevent
a user from sending a signal to another user owned process ?

If it's in pidfd_send_signal(), then, passing the socket through
SCM_RIGHT won't be useful if the target process is not owned by the
same user, or root.

> + * Return: On success, a cloexec pidfd is returned.
> + *         On error, a negative errno number will be returned.
> + */
> +SYSCALL_DEFINE2(pidfd_open, pid_t, pid, unsigned int, flags)
> +{
> +	int fd, ret;
> +	struct pid *p;
> +	struct task_struct *tsk;
> +
> +	if (flags)
> +		return -EINVAL;
> +
> +	if (pid <= 0)
> +		return -EINVAL;
> +
> +	p = find_get_pid(pid);
> +	if (!p)
> +		return -ESRCH;
> +
> +	rcu_read_lock();
> +	tsk = pid_task(p, PIDTYPE_PID);
> +	if (!tsk)
> +		ret = -ESRCH;
> +	else if (unlikely(!thread_group_leader(tsk)))
> +		ret = -EINVAL;
> +	else
> +		ret = 0;
> +	rcu_read_unlock();
> +
> +	fd = ret ?: pidfd_create(p);
> +	put_pid(p);
> +	return fd;
> +}
> +
>  void __init pid_idr_init(void)
>  {
>  	/* Verify no one has done anything silly: */

Regards.

-- 
Yann Droneaud
OPTEYA


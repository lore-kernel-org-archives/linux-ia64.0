From: Manfred Spraul <manfreds@colorfullife.com>
Date: Sat, 03 Jun 2000 17:32:18 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.0-test1)
Message-Id: <marc-linux-ia64-105590678205115@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
>         - ptrace interface should work again (at least strace works...)
> 
There is a race in sys_ptrace that I fixed on i386:

arch/ia64/kernel/ptrace.c ~ line 830:

	read_lock(&tasklist_lock);
	child = find_task_by_pid(pid);
	read_unlock(&tasklist_lock);
************ bad! the task could die!
	if(!child)	
		goto out;

You must call get_task_struct() before read_unlock(&tasklist_lock);

Then you dereference child->mm. child->mm can change, you must call
	task_lock(child);
	task_unlock(child)
around these lines [check fs/proc/*.c]

Btw, child->mm can be NULL.

--
	Manfred




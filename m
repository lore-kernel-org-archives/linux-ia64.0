From: "JWM" <jwm@systemfabricworks.com>
Date: Thu, 25 Jan 2007 21:51:44 +0000
Subject: Re: Spinlock bug??
Message-Id: <002201c740cb$01966240$7401a8c0@Maelstrom>
List-Id: <linux-ia64.vger.kernel.org>
References: <003e01c73fd8$6a46f730$7401a8c0@Maelstrom>
In-Reply-To: <003e01c73fd8$6a46f730$7401a8c0@Maelstrom>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

    Thanks
    When I saw that code you pasted in it became clear. The potential switch 
in CPU's is protected by bumping the usage on the task structure. I haven't 
looked at the exit code, but I would think that should protect this from 
exiting processes wouldn't you?
    ....JW
----- Original Message ----- 
From: "Christoph Lameter" <clameter@sgi.com>
To: "JWM" <jwm@systemfabricworks.com>
Cc: <linux-ia64@vger.kernel.org>; <pj@sgi.com>
Sent: Thursday, January 25, 2007 11:39 AM
Subject: Re: Spinlock bug??


> On Wed, 24 Jan 2007, JWM wrote:
>
>>    Hi all;
>>    I'm working on a Bull - 8 way ia64 system running a RedHat variant of
>> 2.6.17.
>>    I keep getting a spin lock bug and dump , attached.
>>    It appears that cpuset_set_cpus_affinity is taking doing a task_lock 
>> on the
>> task structure and only releaseing it after the cpu has changed. That
>> naturally causes the spin_bug function to get upset.
>>    The lock doesn't appear to be required since set_cpus_allowed makes 
>> sure
>> that things are serialized pretty well.
>>    Am I missing something here or is this lock not required.
>
> Try a newer kernel. That piece was reworked and cpuset_set_cpus_affinity
> no longer exists in recent kernels. 2.6.20-rc6 has:
>
> long sched_setaffinity(pid_t pid, cpumask_t new_mask)
> {
>        cpumask_t cpus_allowed;
>        struct task_struct *p;
>        int retval;
>
>        lock_cpu_hotplug();
>        read_lock(&tasklist_lock);
>
>        p = find_process_by_pid(pid);
>        if (!p) {
>                read_unlock(&tasklist_lock);
>                unlock_cpu_hotplug();
>                return -ESRCH;
>        }
>
>        /*
>         * It is not safe to call set_cpus_allowed with the
>         * tasklist_lock held.  We will bump the task_struct's
>         * usage count and then drop tasklist_lock.
>         */
>        get_task_struct(p);
>        read_unlock(&tasklist_lock);
>
>        retval = -EPERM;
>        if ((current->euid != p->euid) && (current->euid != p->uid) &&
>                        !capable(CAP_SYS_NICE))
>                goto out_unlock;
>
>        retval = security_task_setscheduler(p, 0, NULL);
>        if (retval)
>                goto out_unlock;
>
>        cpus_allowed = cpuset_cpus_allowed(p);
>        cpus_and(new_mask, new_mask, cpus_allowed);
>        retval = set_cpus_allowed(p, new_mask);
>
> out_unlock:
>        put_task_struct(p);
>        unlock_cpu_hotplug();
>        return retval;
> }
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


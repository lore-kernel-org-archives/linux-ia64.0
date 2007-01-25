From: "JWM" <jwm@systemfabricworks.com>
Date: Thu, 25 Jan 2007 21:49:10 +0000
Subject: Re: Spinlock bug??
Message-Id: <001d01c740ca$a5fe0cd0$7401a8c0@Maelstrom>
List-Id: <linux-ia64.vger.kernel.org>
References: <003e01c73fd8$6a46f730$7401a8c0@Maelstrom>
In-Reply-To: <003e01c73fd8$6a46f730$7401a8c0@Maelstrom>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

    Simon;
    I've looked at the code and the function that calls 
cpuset_set_cpus_affinity does a get_task. That bumps the usage count and 
should protect from an exiting process doing evil - shouldn't it?
    So the sched_setaffinity locks, bumps the task useage and then unlocks 
and calls cpuset_set_cpus_affinity. The in the Bull code 
cpuset_set_cpuaffinity takes a spin lock on the structure and then 
(potentially) moves it to another CPU.
    It doesn't look like a change is required other than removing the lock 
in cpuset_set_cpus_affinity.
    Is there a possible race here I'm missing?
    ....JW
----- Original Message ----- 
From: "Simon Derr" <Simon.Derr@bull.net>
To: "JWM" <jwm@systemfabricworks.com>
Cc: <linux-ia64@vger.kernel.org>; "Philippe Garrigues" 
<philippe.garrigues@bull.net>
Sent: Thursday, January 25, 2007 3:12 AM
Subject: Re: Spinlock bug??


>>    Hi all;
>>    I'm working on a Bull - 8 way ia64 system running a RedHat variant of
>> 2.6.17.
>>    I keep getting a spin lock bug and dump , attached.
>
> Hello,
>
> If you are running a Bull Linux kernel, I suggest that you contact
> directly Bull for this kind of issues. We have added a few custom patches
> that could hardly be adressed by other people from this list.
>
> That being said, I'm going to see what's going on in this particular case.
> You're probably right.
>
> Simon.
>
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


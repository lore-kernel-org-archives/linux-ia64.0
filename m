From: Paul Jackson <pj@sgi.com>
Date: Thu, 25 Sep 2003 05:39:44 +0000
Subject: Re: [Lse-tech] Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106446847905842@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444308519469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444308519469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> BTW: What do cpusets provide that couldn't be done with user-level
> tools on top of the existing sched_setaffinity() system call?

I don't see how you can do the migrate_cpuset_processes() from a user
level daemon.  Just because two tasks happen to be allowed on the same
CPUs doesn't mean they are in the same cpuset.  The kernel must track,
across forks, which tasks share a given cpuset.

There are also some resource management capabilities, such as tracking
and controlling how much memory a cpuset takes, and swapping (with
possible oom kill) against a cpuset that one can consider extending this
to, but only if it's in the kernel.  But I'm not ready to push this
point ... yet.

And the permission model has to remain a rather primitive "root can do
anything, anyone else can just subset their parent" if it lacks kernel
hooks to track uid/suid ownership of each cpuset.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373

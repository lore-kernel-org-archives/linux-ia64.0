From: Khalid Aziz <khalid@fc.hp.com>
Date: Wed, 10 Oct 2001 22:53:26 +0000
Subject: Re: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805326@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

That sounds interesting. You could use it on init task as David
suggested and set the behavior for all tasks. But how would you
implement it form a user space tool like "prctl". sys_prctl() operates
on the current task only. Are you planning to add another system call?

--
Khalid

Jesse Barnes wrote:
> 
> I was thinking of hacking up the 'prctl' tool to take a PID as an
> argument, that way it could set the flags for any task.  It would allow
> an initscript to set init's flags, among other things.  Would such a
> change qualify as a cleaner solution?
> 
> Jesse
> 

==================================
Khalid Aziz                              Linux Systems Operation R&D
(970)898-9214                                        Hewlett-Packard
khalid@fc.hp.com                                    Fort Collins, CO


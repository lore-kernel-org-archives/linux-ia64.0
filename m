From: Keith Owens <kaos@sgi.com>
Date: Tue, 14 Feb 2006 05:13:07 +0000
Subject: Re: [Patch]IA64 kexec
Message-Id: <7424.1139893987@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1131406068.2524.15.camel@linux-znh>
In-Reply-To: <1131406068.2524.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Horms (on Tue, 14 Feb 2006 13:06:44 +0900) wrote:
>On Tue, Feb 14, 2006 at 08:17:35AM +1100, Keith Owens wrote:
>> Which raises a small problem.  As of about 2.6.15, INIT is a
>> recoverable event.  INIT _must_ be recoverable, because it can be sent
>> when an MCA occurs and one or more cpus was running with interrupts
>> disabled.  For example, when the cpu that takes the MCA owns a disabled
>> spinlock that other cpus are waiting on.  If INIT is not recoverable
>> then some MCAs that could be recovered also become unrecoverable, at
>> random.
>> 
>> Since INIT is recoverable, pressing NMI gives you a stack trace for
>> each cpu, then the system resumes.  This allows a user to see if the
>> system is making progress, albeit slowly, or if it really is stuck.
>> The downside of a recoverable INIT is that you cannot use it to take a
>> dump, or at least not the first time that NMI is issued.  Unfortunately
>> there is no way to distinguish between an NMI where the user wants to
>> see what the system is doing and an NMI to take a dump.  Nobody has
>> implemented the "Read Programmer's Mind" instruction yet.
>
>I sense pain. Looking over the code - very naievely - would it be
>possible to register an alternate INIT handler when kexecing.

Not a good idea, the INIT handler code is very closely tied to the
SAL/OS interface.  But what kexec can do is to register itself on the
notify_die() chain, it will get called for multiple events including
DIE_INIT_SLAVE_ENTER, DIE_INIT_SLAVE_PROCESS, DIE_INIT_SLAVE_LEAVE,
DIE_INIT_MONARCH_ENTER, DIE_INIT_MONARCH_PROCESS and
DIE_INIT_MONARCH_LEAVE.  That chain and the associated events is meant
for debuggers, crash dumpers and assorted RAS tools.  See also the
DIE_MCA_* events on the same chain.


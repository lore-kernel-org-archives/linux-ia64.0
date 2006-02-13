From: Keith Owens <kaos@sgi.com>
Date: Mon, 13 Feb 2006 21:17:35 +0000
Subject: Re: [Patch]IA64 kexec
Message-Id: <21149.1139865455@ocs3>
List-Id: <linux-ia64.vger.kernel.org>
References: <1131406068.2524.15.camel@linux-znh>
In-Reply-To: <1131406068.2524.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" (on Mon, 13 Feb 2006 09:26:58 -0800) wrote:
>The ia64 equivalent of NMI (large brick through the window) is INIT.
>Some systems have a button on the front panel to generate INIT, or
>have a maintenance processor that can send INIT.  So a good kdump
>solution should eventually make use of INIT.

Which raises a small problem.  As of about 2.6.15, INIT is a
recoverable event.  INIT _must_ be recoverable, because it can be sent
when an MCA occurs and one or more cpus was running with interrupts
disabled.  For example, when the cpu that takes the MCA owns a disabled
spinlock that other cpus are waiting on.  If INIT is not recoverable
then some MCAs that could be recovered also become unrecoverable, at
random.

Since INIT is recoverable, pressing NMI gives you a stack trace for
each cpu, then the system resumes.  This allows a user to see if the
system is making progress, albeit slowly, or if it really is stuck.
The downside of a recoverable INIT is that you cannot use it to take a
dump, or at least not the first time that NMI is issued.  Unfortunately
there is no way to distinguish between an NMI where the user wants to
see what the system is doing and an NMI to take a dump.  Nobody has
implemented the "Read Programmer's Mind" instruction yet.


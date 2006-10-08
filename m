From: Keith Owens <kaos@sgi.com>
Date: Sun, 08 Oct 2006 07:37:04 +0000
Subject: Re: Sending cpu 0 back to SAL slave loop
Message-Id: <8352.1160293024@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061006203909.GA6500@sgi.com>
In-Reply-To: <20061006203909.GA6500@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Wilcox (on Fri, 6 Oct 2006 14:44:43 -0600) wrote:
>On Fri, Oct 06, 2006 at 03:39:10PM -0500, Jack Steiner wrote:
>> For kexec, it is ESSENTIAL that all cpus except for the one doing
>> the kexec be returned to the SAL slave loop. If this is not done, our
>> chipset will misdirect IO interrupts on the newly exec'ed kernel.
>
>Could you do an IPI call to have CPU 0 do the kexec and have the CPU
>that sent the IPI fall into the SAL slave loop instead?

An IPI call will not work for MCA or INIT.  Both of those drive all
cpus into a state which has disabled interrupts.


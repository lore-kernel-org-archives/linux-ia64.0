From: Erich Focht <efocht@hpce.nec.com>
Date: Thu, 11 Sep 2003 11:33:20 +0000
Subject: Re: [Linux-ia64] PATCH redirectable IRQs
Message-Id: <marc-linux-ia64-106328030119143@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805756@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 10 September 2003 20:26, Michael.Meduna@Bull.com wrote:
> Is it possible to set the Linux XTP values from either a system command or
> function?  I would like to set the default route for the IRQs in /proc/irq
> to CPU 0 in lowest priority mode.  Obviously, this can be done via the
> smp_affinity interface.  In fact, it appears that the default is CPU 0 in
> lowest priority mode.  But then, I would like to permanently disable
> interrupts for specific CPUs.  Can this be done?

Hi,
if the interface didn't change, you should be able to set the IRQ
routing to "fixed" through the smp_affinity /proc interface. An
attempt to explain this is in Documentation/ia64/IRQ-redir.txt

Regards,
Erich



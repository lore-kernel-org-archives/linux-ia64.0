From: "Michael Meduna" <michael.meduna@bull.com>
Date: Fri, 12 Sep 2003 01:36:39 +0000
Subject: Re: [Linux-ia64] PATCH redirectable IRQs
Message-Id: <marc-linux-ia64-106333061218151@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805756@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Erich, I have already reviewed the referenced document.  I understand how to
set lowest priority delivery mode or fixed delivery mode for a specific IRQ.
What I would like to do is set CPU 0 in lowest priority delivery mode for
all IRQs but then, have the ability to permanently disable interrupts for
specific CPUs.

For example:  lets say I have a system with 8 host CPUs.  I create a
processor set that will contain a pool of CPUs (0-3).  I create another set
of processor sets (4 of them) that will contain processors 4-7.  All IRQs
are set to CPU 0 in lowest priority delivery mode.  I do not want processors
4-7 to take an interrupt.  However, I do want interrupts to be spread across
processors 0-3.  Is there a way to set the XTP register such that processors
4-7 will never take an interrupt?


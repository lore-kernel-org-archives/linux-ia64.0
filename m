From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sat, 18 Oct 2003 01:31:37 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106644074523554@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 05:49:55PM -0700, Andrew Morton wrote:
> David Mosberger <davidm@napali.hpl.hp.com> wrote:
> >
> > One philosophy states that if
> > your kernel touches random addresses, it's better to signal a visible
> > error (machine-check) than to risk silent data corruption.
> 
> An access to an illegal address should generate a fault, period.  This puts
> the processing into the hands of software.  If software chooses to silently
> ignore the fault (ie: "silent data corruption") then it is poorly designed.

It *does* signal a fault, in the form of a machine check.  On other
architectures I'm familiar with this is usually implemented as an
interrupt, but the idea is similar - when the system bus controller
detects a bad address on the bus, it returns all 1s (for a read) and
signals an interrupt.  Usually you can turn this interrupt off (and
most likely you can on Itanium chipsets too) but that is not a good
idea.

The problem is that this interrupt is not synchronous with respect to
the instruction stream, and this makes it difficult for software to
recover from, particularly in a monolithic system like Linux where you
can't just terminate the faulting driver.  The best you can usually do
is to print the details and hope that it's a once-off.  It is not
something that you can sensibly use to abort copy_*_user.

In any case touching random addresses is just plain bad.  What if
there's a device mapped there which happens to have read side effects
like clearing the interrupt cause, so e.g. every time you read /dev/mem
you cause a timeout on your SCSI bus :)

Matt


From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 06 Oct 2006 20:44:43 +0000
Subject: Re: Sending cpu 0 back to SAL slave loop
Message-Id: <20061006204443.GT2563@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061006203909.GA6500@sgi.com>
In-Reply-To: <20061006203909.GA6500@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 06, 2006 at 03:39:10PM -0500, Jack Steiner wrote:
> For kexec, it is ESSENTIAL that all cpus except for the one doing
> the kexec be returned to the SAL slave loop. If this is not done, our
> chipset will misdirect IO interrupts on the newly exec'ed kernel.

Could you do an IPI call to have CPU 0 do the kexec and have the CPU
that sent the IPI fall into the SAL slave loop instead?

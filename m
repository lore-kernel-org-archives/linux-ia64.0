From: Greg KH <greg@kroah.com>
Date: Mon, 20 May 2002 17:59:22 +0000
Subject: Re: [Linux-ia64] Add reserved number for security syscall
Message-Id: <marc-linux-ia64-105590701905586@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905580@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905580@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 15, 2002 at 05:17:33PM -0700, richard offer wrote:
> 
> 
> Please apply the attached patch (against 2.4.18) to reserve a syscall
> number for the security interface.
> 
> 
> A number has already been reserved and accepted by Linus for the i386,
> alpha and cris architectures, at the time the reservation was requested,
> none of the LSM developers had IA64 machines so it slipped through the
> cracks.

Not true, I have access to ia64 hardware, and have successfully run LSM
modified kernels on them in the past.  I was merely waiting for the LSM
code to make it into the mainline kernel before bothering the other arch
maintainers.

Thanks David for accepting this patch and reserving a number for us.

greg k-h


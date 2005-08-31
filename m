From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 31 Aug 2005 16:27:09 +0000
Subject: Re: 2.6.13 does not boot on Eiger
Message-Id: <200508311027.09473.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jefysr9gc7.fsf@sykes.suse.de>
In-Reply-To: <jefysr9gc7.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 31 August 2005 10:18 am, Andreas Schwab wrote:
> Bjorn Helgaas <bjorn.helgaas@hp.com> writes:
> 
> > Does the MCA log say anything useful?
> 
> How can I find out?

On HP boxes, you can do "errdump mca" (for zx1 boxes) or
"errdump all mca" (for sx1000 boxes) at the EFI shell.
If you can boot a working kernel, salinfod will also
extract the logs and drop them in /var/log/salinfo.
There's a decoded/ directory, which is basically the
same output as "errdump", and a raw/ directory, which
contains binary files that can be run through a decoder
(which is unfortunately proprietary).

> > P.S.  What is your firmware "acpiconfig" mode? My eiger is
> > in "default" mode,
> 
> Likewise.

Type "acpiconfig" at the EFI shell prompt.

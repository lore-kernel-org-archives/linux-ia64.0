From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 13 Jan 2006 15:05:07 +0000
Subject: Re: Preserving CMC/CPE records across reboot
Message-Id: <1137164707.24261.19.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <14947.1137113189@ocs3.ocs.com.au>
In-Reply-To: <14947.1137113189@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-01-13 at 11:46 +1100, Keith Owens wrote:
> 
> We should be able to keep the first few CMC/CPE records for each cpu in
> NVRAM and discard the later ones if we start getting a backlog.  Then
> if the system hangs while processing a CMC/CPE, the data will still be
> available in NVRAM and will be processed on the next boot.  If the
> reboot hangs again in salinfo processing then we have a solid error,
> either cpu or SAL, so switch the offending cpu out of the system.
> 
> Any objections from other platforms?

Keith,

   Sorry, it's been a while since I've looked at this code, but how do
we determine how many records can be stored in NVRAM?  I would guess
that for CPEs at least, it's platform dependent.  If it can be done w/o
losing records, it's probably ok, but I'm not sure I understand the
details.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab


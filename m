From: Grant Grundler <iod00d@hp.com>
Date: Tue, 24 Jun 2003 21:07:17 +0000
Subject: Re: SCSI ERRORS triggered by BIO_VMERGE_BOUNDARY
Message-Id: <marc-linux-ia64-105648893606349@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604433402604@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604433402604@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 23, 2003 at 03:05:49PM -0700, Grant Grundler wrote:
> It looks like blk_recount_segments() is only used to gather
> stastics about how many segments are in the transaction.
> I tracked back to fs/bio.c to find the consumer of this
> information (# of segments) but didn't find it.
> Anyone know off hand?

James Bottomley explained it to me:

| The second is this nr_phys_segments in the elevator queuing code.  This   
| counts the number of SG entries that will be required to describe the
| request.  A lot of devices have fixed size SG tables, so the SG table is
| the only thing that limits the size of the transfer.  Thus the block
| layer has code that tries to merge physically contiguous segments of a
| bio so it can squeeze extra blocks into the transfer.

I don't know if LSI SCSI controllers/drivers have limits in this space
and what they might be. Will try to figure that out.

thanks,
grant

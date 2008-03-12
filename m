From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 12 Mar 2008 01:08:27 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <28400.1205284107@ocs10w>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson (on Tue, 11 Mar 2008 16:22:21 -0500) wrote:
>On Tue, Mar 11, 2008 at 03:07:20PM +0100, Zoltan Menyhart wrote:
>> I still don't see any need for many buffers.
>
>In testing, I found one of the records getting dropped in salinfo.c
>at the comment "saved record changed by mca.c since interrupt, discard it".
>That code was not added by your patch, but is something that
>impacts logging.

A record getting dropped at that point indicates a race between
salinfo.c and mca.c.  salinfo.c is running under spin_lock_irqsave
which is normally safe, but mca.c can be driven at any time and it
completely ignores spin_lock_irqsave.  mca.c grabs the next free buffer
in the circular list and overwrites that buffer.  The record id check
detects that mca.c has overwritten this buffer while salinfo.c was
processing it and retries the extraction of the record to user space.

By definition whatever record was originally in the buffer has now been
lost.  Was the lost record of any use?  No way of telling.  The only
way to avoid that loss is to increase the number of buffers.

Any repeated sequence of recoverable MCA events will result in some
loss of data, no matter how many buffers you allocate, simply because
MCA processing has a higher priority than user space processing.


From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Jun 2003 22:14:44 +0000
Subject: Re: SCSI ERRORS triggered by BIO_VMERGE_BOUNDARY
Message-Id: <marc-linux-ia64-105640705631100@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604433402604@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604433402604@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Jun 2003 15:05:49 -0700, Grant Grundler <iod00d@hp.com> said:

  >> The decision has to be split across BIO and I/O MMU: only the
  >> BIO-level knows what to do if merging _cannot_ take place and
  >> only the I/O MMU code knows how to map physically discontiguous
  >> pages linearly into I/O MMU space.

  Grant> I understand the latter. Not the former.

  Grant> It looks like blk_recount_segments() is only used to gather
  Grant> stastics about how many segments are in the transaction.  I
  Grant> tracked back to fs/bio.c to find the consumer of this
  Grant> information (# of segments) but didn't find it.  Anyone know
  Grant> off hand?

I think you're talking to the wrong people.  If you want to change the
BIO layer, talk to Jens Axboe et al.

	--david

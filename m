From: Jack Steiner <steiner@sgi.com>
Date: Fri, 13 Jan 2006 15:57:02 +0000
Subject: Re: Preserving CMC/CPE records across reboot
Message-Id: <20060113155702.GB17542@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <14947.1137113189@ocs3.ocs.com.au>
In-Reply-To: <14947.1137113189@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 13, 2006 at 11:46:29AM +1100, Keith Owens wrote:
> CMC/CPE records (unlike MCA/INIT) are copied into kernel space and
> cleared from NVRAM as soon as they occur.  That decision was made by
> Bjorn Helgaas some years ago.  The idea is that if you do not have
> salinfo_decode or some equivalent program running then the correctable
> errors still need to be deleted from NVRAM.  But if the system hangs
> while reading the CMC/CPE then we get no data at all.
> 
> SGI just had an example of this.  A cpu took a CMC, salinfo_decode
> started running and hung while processing the CMC record, the system
> had to be rebooted.  Because the CMC record had been cleared from NVRAM
> before handing a copy to salinfo_decode, the contents were lost.

On SN, CMC/CPE records are never written to NVRAM. They are saved only
in memory. If the system hangs trying to log a CMC/CPE & the system is reset,
all CMC/CPE records are lost.

It is possible that some of this could be changed but it currently works 
this way. Also, writing error records to NVRAM is slow - something to
avoid on performance critical paths. I suppose we could threshhold the
error rate & would limit the rate of writing to NVRAM.



> 
> We should be able to keep the first few CMC/CPE records for each cpu in
> NVRAM and discard the later ones if we start getting a backlog.  Then
> if the system hangs while processing a CMC/CPE, the data will still be
> available in NVRAM and will be processed on the next boot.  If the
> reboot hangs again in salinfo processing then we have a solid error,
> either cpu or SAL, so switch the offending cpu out of the system.
> 
> Any objections from other platforms?
> 

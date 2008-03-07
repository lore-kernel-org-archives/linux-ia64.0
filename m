From: Russ Anderson <rja@sgi.com>
Date: Fri, 07 Mar 2008 16:55:54 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <20080307165553.GA32384@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 07, 2008 at 01:02:47PM +0100, Zoltan Menyhart wrote:
> Russ Anderson wrote:
> 
> >Figure 2-1 does show SAL passing up CPEI records to OS, too.
> 
> Yes, as I also said:
> "The SAL / PAL can be the origin of CPEIs / CMCIs if they succeed
> in correcting MCAs. They stock the related information until the
> OS calls SAL_GET_STATE_INFO()."
> 
> I Just want to emphasize that in case of the platform / CPU HW originated
> CPEIs / CMCIs, the SAL does not know of them before we call
> SAL_GET_STATE_INFO(), therefore it cannot store any information about
> them.

In some implementations SAL builds the records in response to 
SAL_GET_STATE_INFO(), in other implementations SAL knows of 
the CPEI/CMCI and builds/buffers the records before the
SAL_GET_STATE_INFO() call.  The SAL spec does not prohibit SAL 
building/buffering the records before SAL_GET_STATE_INFO().

From a practical perspective, I don't think the difference significantly
changes how linux should handle CPEIs/CMCIs.  Linux should try to read/log
the CPEI/CMCI as quick as possible.  The lack of SAL buffering increases
the chance of a record getting lost (overwritten) while SAL buffering
reduces the chance that a CPEI/CMCI record gets lost (overwritten).
If anything, the lack of SAL buffering would be a reason for more
linux buffers, to reduce the chance of losing records.

> >See section 5.3.2 CMC and CPE Records
> >
> >  Each processor or physical platform could have multiple valid corrected
> >  machine check or corrected platform error records. The maximum number of
> >  these records present in a system depends on the SAL implementation and
> >  the storage space available on the system. There is no requirement for
> >  these records to be logged into NVM. The SAL may use an implementation
> >  specific error record replacement algorithm for overflow situations. The
> >  OS needs to make an explicit call to the SAL procedure 
> >  SAL_CLEAR_STATE_INFO
> >  to clear the CMC and CPE records in order to free up the memory resources
> >  that may be used for future records.
> 
> As far as I can understand, it is about the events not signaled by
> interrupts, but MCAs, and either the PAL or the SAL manages to correct
> them (=> CMCI, CPEI).

Agreed that SAL corrected errors can get passed up as CMCI/CPEI.
I do not believe it prohibits other CMCI/CPEI records from being
built/buffered before the SAL_CLEAR_STATE_INFO() call.  

As stated above, from a practical perspective, I don't believe the
difference significanlty changes how linux should behave other than
possibly being a reason for more linux buffers.

> You have got N >= 1 buffers for this kind of errors.

My preference is for a larger N.  Scaling N with system size
may be the best solution for small & large systems.

> >5.4.1 Corrected Error Event Record
> >
> >  In response to a CMC/CPE condition, SAL builds and maintains the error
> >  record for OS retrieval.
> 
> It does not say that the SAL knows about CMCI / CPEI signaled errors
> before we call SAL_GET_STATE_INFO().

It does not say that SAL cannot know before the SAL_GET_STATE_INFO() call.

> Example: the Tiger box with i82870:

I take your word as how Tiger SAL behaves.
Please take my word that other SAL implementations behave differently.


Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

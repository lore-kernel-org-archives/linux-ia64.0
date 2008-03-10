From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 10 Mar 2008 09:36:11 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <47D5010B.2020003@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:

> ... in other implementations SAL knows of
> the CPEI/CMCI and builds/buffers the records before the
> SAL_GET_STATE_INFO() call.

If you mean MCAs corrected and transformed into CPEIs/CMCIs, I agree.
If you mean the platform / CPU HW originated CPEIs/CMCIs, please
explain how the SAL catches these interrupts.

I guess the differences among implementations call for a dynamically
configurable solution.

First I would have liked to discuss about the MCAs, which - in may
approach - are completely separated from the CPEIs/CMCIs.
As MCA log buffering cannot be synchronized as it is done
for the CPEIs/CMCIs, it requires different code, can we discuss
separately the mechanisms for MCAs and CPEIs/CMCIs?
As far as the my MCA stuff is concerned, can you agree that it is
safer than the original code?

>>From a practical perspective, I don't think the difference significantly
> changes how linux should handle CPEIs/CMCIs.  Linux should try to read/log
> the CPEI/CMCI as quick as possible. The lack of SAL buffering increases
> the chance of a record getting lost (overwritten) while SAL buffering
> reduces the chance that a CPEI/CMCI record gets lost (overwritten).
> If anything, the lack of SAL buffering would be a reason for more
> linux buffers, to reduce the chance of losing records.

I agree.

> Agreed that SAL corrected errors can get passed up as CMCI/CPEI.
> I do not believe it prohibits other CMCI/CPEI records from being
> built/buffered before the SAL_CLEAR_STATE_INFO() call.  

How can it build / buffer records belonging to the platform / CPU HW
originated CPEIs/CMCIs?
Some of the CPEI/CMCI arrows on the Figure 2-1.... go directly from the
platform / CPU HW to the OS.
And as far as I can see, the SAL do not handle CPE/CMC interrupts.

> As stated above, from a practical perspective, I don't believe the
> difference significanlty changes how linux should behave other than
> possibly being a reason for more linux buffers.

> My preference is for a larger N.  Scaling N with system size
> may be the best solution for small & large systems.

Can we think of some dynamic / platfom dependent way of configuring
the number of the buffers?

E.g. my MCA stuff can start up with, say, 3 buffers by default,
and you will be able to override it by a boot command line option.

Thanks,

Zoltan

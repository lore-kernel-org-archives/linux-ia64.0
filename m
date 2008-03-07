From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 07 Mar 2008 12:02:47 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <47D12EE7.3090906@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:

> Figure 2-1 does show SAL passing up CPEI records to OS, too.

Yes, as I also said:
"The SAL / PAL can be the origin of CPEIs / CMCIs if they succeed
in correcting MCAs. They stock the related information until the
OS calls SAL_GET_STATE_INFO()."

I Just want to emphasize that in case of the platform / CPU HW originated
CPEIs / CMCIs, the SAL does not know of them before we call
SAL_GET_STATE_INFO(), therefore it cannot store any information about
them.

> See section 5.3.2 CMC and CPE Records
> 
>   Each processor or physical platform could have multiple valid corrected
>   machine check or corrected platform error records. The maximum number of
>   these records present in a system depends on the SAL implementation and
>   the storage space available on the system. There is no requirement for
>   these records to be logged into NVM. The SAL may use an implementation
>   specific error record replacement algorithm for overflow situations. The
>   OS needs to make an explicit call to the SAL procedure SAL_CLEAR_STATE_INFO
>   to clear the CMC and CPE records in order to free up the memory resources
>   that may be used for future records.

As far as I can understand, it is about the events not signaled by
interrupts, but MCAs, and either the PAL or the SAL manages to correct
them (=> CMCI, CPEI).

You have got N >= 1 buffers for this kind of errors.

> 5.4.1 Corrected Error Event Record
> 
>   In response to a CMC/CPE condition, SAL builds and maintains the error
>   record for OS retrieval.

It does not say that the SAL knows about CMCI / CPEI signaled errors
before we call SAL_GET_STATE_INFO().

Example: the Tiger box with i82870:

There is a register pair of FERRST / SERRST for each component, e.g.
the memory controller.

FERRST: first error status register
SERRST: second / subsequent error status register

Note that the FERRST captures correctly the errors, the SERRST
is mixture (OR logic) of all the other errors.

In case of a corrected memory error, the OS receives a CPEI.
When the OS calls SAL_GET_STATE_INFO(), the SAL reads out the
FERRST / SERRST for each component.
If there are multiple errors, the SAL selects which one is to be
reported.
When the OS calls SAL_CLEAR_STATE_INFO(), the SAL resets the
register pairs whose content were reported by SAL_GET_STATE_INFO().
If there are multiple errors, then you can SAL_GET_STATE_INFO()
repeatedly.

> Here is a manufacturer advertising "over 7 years".
> 7 years is 61,320 hrs, 8 year is 70,080.

It seems to be way too low.
Would not it mean:
"99.999% probability that the product will operate for over 7 years without a failure"
instead of being an MTBF value?

Please have a look at e.g.: http://ramfinder.com/items/ex2gb0132f.html

They mean "without a failure": uncorrectable errors.


Luck, Tony wrote:

> Russ's large systems change these.  Is 30,000 hours a plausible
> MTBF for a DIMM.  What if the system contains 8TB memory in 2GB
> DIMMs.  Now you have 4096 DIMM sticks in the system.  Redo your
> calculations for this large system.

Using the memory seen at http://ramfinder.com/items/ex2gb0132f.html

7 years * 100% / (100% - 99.999%) / 4096 = 170 years

i.e. the MTBF: > 1,000,000 hours with 4096 DIMMs.

> ... about 1 error per gigabyte per two months.

It can be an estimation for the single bit error rate (CPEI).

> But that was a very old study ... newer DIMMs made on denser
> silicon processes will most likely be more vulnerable to
> neutron strikes.

Let's assume the flux of cosmic ray generated particles will hit
the same number of memory cells, unless a particle comes // to the
silicon die, then it can hit more cells until its energy is eaten up.

This is why I think it is the "surface" of the memory exposed
to the flux of cosmic ray generated particles, that is important
and not the number of the gigabytes.

Thanks,

Zoltan





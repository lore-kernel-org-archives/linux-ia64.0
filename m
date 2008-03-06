From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 06 Mar 2008 13:14:48 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <47CFEE48.90803@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:

Let's see this first:

> Obviously entering polling
> mode puts the responsibility onto SAL to keep track of all
> the error reports

Please have a look at the
Figure 2-1. Itanium=AE Processor Family Firmware Machine Check Handling Mod=
el
in the Error Handling Guide.

This figure shows that the SAL (or the PAL) cannot see the platform
originated CPEIs, nor the CPU HW originated CMCIs.

When you call SAL_GET_STATE_INFO(), the SAL (and the PAL) will read out
the error status from some HW registers.

Therefore the SAL / PAL cannot store error reports.

Can the HW (platform or CPU) help to save error reports?

A typical "error register set" - whatever it is - saves the first
error and maintains a "cumulative error" status (usually reset
by SAL_CLEAR_STATE_INFO()).

CPEs / CMCs will be lost unless you (want to) "swallow" them
quickly enough.

The SAL / PAL can be the origin of CPEIs / CMCIs if they succeed
in correcting MCAs. They stock the related information until the
OS calls SAL_GET_STATE_INFO().
How many such outstanding CPEIs / CMCIs there can be is an
implementation issue.
Surely there are a limited number of bufferers there.
I do not think they date to implement a complicated buffer
handling mechanism in an MCA context.

- but nobody ever complained that this
> might result in the loss of error information if the SAL runs
> out of space to keep the error records before the next poll
> from the OS. ["solving" problems by shifting the blame point?]

I've got a Tiger box like machine installed with some known
to be bad memory. I scan the known bad addresses via /dev/mem:

	volatile unsigned char *p =3D bad ph. addr.
        for (;;){
                tmp +=3D *p;
                ia64_fc((void *) p);
        }

It is a deterministically bad memory location.
You can guess how many errors / sec there are.
Obviously, we switch into polling mode.
(And we lose most of the events.)

Less than half of the cases I get logs like this:

  Platform Memory Device Error Info Section
  Mem Error Detail
    Physical Address: 0x280059b81 Address Mask: 0xfffffffff80 Node: 0
	Card: 0 Module: 3 Bank: 3 Device: 1 Row: 2050 Column: 1356
  Platform Memory Device Error Info Section
  Mem Error Detail
    Node: 0

But in more than half of the cases, salinfo_decode gets lost:

  Platform Memory Device Error Info Section
  Mem Error Detail
    Node: 0 =20

Again we lose events.

The SAL spec. does not say a word about how many errors have to be
kept by the SAL. Therefore we cannot reckon on the SAL keeping them.

> Both the CMC and CPE interrupt paths have code to switch to
> polling mode in the presence of a burst of correctable errors.
> Can we tune this threshold w.r.t. the number of buffers we
> pre-allocate to save error records so that we (the OS) won't
> be responsible for losing errors?

We are condemned to lose error logs due to the limited number
of the error buffers in the SAL / PAL / OS, due to the limited
services provided by the HW.

I hope we can agree that the probability of a coincidence of more
that one independent errors is very very low
(otherwise change the machine :-)).

Keeping the first error log that contains pertinent, new
information, is very important.
Keeping the last one is important, because not treating rapidly
enough an error can worsen the situation.
The others are just for the statistics...

Thanks,

Zoltan









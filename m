From: Andreas Hirstius <Andreas.Hirstius@cern.ch>
Date: Wed, 06 Apr 2005 08:33:07 +0000
Subject: Re: [Gelato-technical] Serious performance degradation on a RAID
Message-Id: <42539EC3.9000305@cern.ch>
List-Id: <linux-ia64.vger.kernel.org>
References: <16978.62532.841151.100745@napali.hpl.hp.com>
In-Reply-To: <16978.62532.841151.100745@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org



Chen, Kenneth W wrote:

>On Tue, Apr 05, 2005 at 09:45:34PM -0700, David Mosberger wrote:
> =20
>
>>Did you compile the driver as a module?
>>   =20
>>
>
>
>Duraid Madina wrote on Tuesday, April 05, 2005 9:53 PM
> =20
>
>>Nope. You're not seeing the problem?
>>   =20
>>
>
>That is the reason for the performance problem.  And this is definitely
>*not* ia64 specific.  See this discussion which started with performance
>problem seen on opteron and reproduced on DELL machine as well.
>http://marc.theaimsgroup.com/?t=111028927300002&r=3D1&w=3D2
>
>The changeset that david pointed out is the right fix.  Or you can just
>take the small patch I posted in the above thread.
>
> =20
>

The problems mentioned in this discussion about the Fusion-MPT I can=20
perfectly reproduce on my boxes with 2.6.11, but only with pages sizes=20
4k and 8k;
With 16k and 64k pages I don't see any problem at all !!!
Actually I see block size <-> page size correlations which are similiar=20
to the correlations I see in my setup...
i.e. 2.6.11 and 4k pages:
    dd ...bs@96: 40MB/s
    dd ...bs=8192: 74MB/s

i.e. 2.6.11 and 8k pages:
    dd ...bs=8192: 56MB/s
    dd ...bs=16384: 74MB/s
  =20
with the driver as module I don't see any change (??).
And I also don't see any change in performance for 4k/8k pages, when=20
applying either your small patch or the cset david pointed to...
Since the fusion-mpt driver in 2.6.12-rc2 has this cset applied and no=20
other changes, I also don't see improvements with this kernel...
(Again with 16k or 64k pages no performance problem in 2.6.12-rc2 with=20
the fusion-mpt driver...)

But the driver in questions is 3w-9xxx and there have been no chances at=20
all in this driver between 2.6.10 and 2.6.12-rc1. The changed driver in =20
-rc2 still has the problem.
And I've tried the driver built-in and as a module (default)...

Andreas

>- Ken
>
>
>
> =20
>

From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 06 Apr 2005 21:50:13 +0000
Subject: RE: [Gelato-technical] Serious performance degradation on a RAID withkernel 2.6.11
Message-Id: <200504062150.j36LoEg31463@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16978.62532.841151.100745@napali.hpl.hp.com>
In-Reply-To: <16978.62532.841151.100745@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Andreas Hirstius wrote on Wednesday, April 06, 2005 1:33 AM
> The problems mentioned in this discussion about the Fusion-MPT I can
> perfectly reproduce on my boxes with 2.6.11, but only with pages sizes
> 4k and 8k;
> With 16k and 64k pages I don't see any problem at all !!!
> Actually I see block size <-> page size correlations which are similiar
> to the correlations I see in my setup...
> i.e. 2.6.11 and 4k pages:
>     dd ...bs@96: 40MB/s
>     dd ...bs=8192: 74MB/s
>
> i.e. 2.6.11 and 8k pages:
>     dd ...bs=8192: 56MB/s
>     dd ...bs=16384: 74MB/s

It is very odd.  I think it has something to do with generic file read
ahead logic.  The read ahead window did not push far enough to keep the
disk busy.  Some of the size calculation are in unit of page, so smaller
page size will have smaller effective read ahead size.  Try look into
mm/readahead.c.  I bet you can find the answer to your performance problem
there.  If not, then I guess we have to keep on looking ;-)




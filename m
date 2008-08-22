From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Fri, 22 Aug 2008 23:02:53 +0000
Subject: Re: kernel unaligned accesses on IA64 in IDE
Message-Id: <20080822230253.GA27056@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080819225606.GB22088@us.ibm.com> <20080822164538.GB9047@us.ibm.com> <9ea470500808221029l6bd79c62w4c06d948f962d95c@mail.gmail.com> <200808222036.00536.bzolnier@gmail.com> <57C9024A16AD2D4C97DC78E552063EA309EDE187@orsmsx505.amr.corp.intel.com> <200808222036.m7MKa6bT008897@agluck-lia64.sc.intel.com> <20080822211447.GA7097@gollum.tnic>
In-Reply-To: <20080822211447.GA7097@gollum.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <petkovbb@googlemail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Robin Holt <holt@sgi.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, axboe@kernel.dk

On 22.08.2008 [23:14:47 +0200], Borislav Petkov wrote:
> [adding Jens to CC: ]
> 
> On Fri, Aug 22, 2008 at 01:36:06PM -0700, Luck, Tony wrote:
> > > How about long instead of int.  int leaves us with the possibility that
> > > something else will expect 8 byte alignment.
> > 
> :> How about this?
> > 
> > Align __cmd to ward off kernel unaligned access consoles messages on
> > ia64 (and perhaps make an almost imperceptible performance improvement
> > on other architectures that can handle unaligned access, but do so
> > more slowly than aligned accesses).
> > 
> > Signed-off-by: Tony Luck <tony.luck@intel.com>
> 
> Tested-by: Borislav Petkov <petkovbb@gmail.com>

Tested-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

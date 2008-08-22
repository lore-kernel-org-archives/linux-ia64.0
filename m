From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 22 Aug 2008 23:30:48 +0000
Subject: RE: kernel unaligned accesses on IA64 in IDE
Message-Id: <57C9024A16AD2D4C97DC78E552063EA309EDE4A3@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080819225606.GB22088@us.ibm.com>
 <20080822164538.GB9047@us.ibm.com>
 <9ea470500808221029l6bd79c62w4c06d948f962d95c@mail.gmail.com>
 <200808222036.00536.bzolnier@gmail.com>
 <57C9024A16AD2D4C97DC78E552063EA309EDE187@orsmsx505.amr.corp.intel.com>
 <200808222036.m7MKa6bT008897@agluck-lia64.sc.intel.com>
 <20080822211447.GA7097@gollum.tnic> <20080822230253.GA27056@us.ibm.com>
In-Reply-To: <20080822230253.GA27056@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nishanth Aravamudan <nacc@us.ibm.com>, Borislav Petkov <petkovbb@googlemail.com>
Cc: Robin Holt <holt@sgi.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, "axboe@kernel.dk" <axboe@kernel.dk>, James Bottomley <James.Bottomley@HansenPartnership.com>

> > > Signed-off-by: Tony Luck <tony.luck@intel.com>
> >
> > Tested-by: Borislav Petkov <petkovbb@gmail.com>
>
> Tested-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks guys for testing my crappy patch ... if you could test
James Bottomley's much better one, that would be wonderful.
My kernel boots ok with James' patch applied ... but I
don't get the unaligned kernel references (no ide-cd drive
on my box ... so I'm probably not executing any of these
code paths).

James: there's no Signed-off-by on your patch.

-Tony

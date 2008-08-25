From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Mon, 25 Aug 2008 16:31:12 +0000
Subject: Re: kernel unaligned accesses on IA64 in IDE
Message-Id: <20080825163111.GA9279@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080819225606.GB22088@us.ibm.com> <20080822164538.GB9047@us.ibm.com> <9ea470500808221029l6bd79c62w4c06d948f962d95c@mail.gmail.com> <200808222036.00536.bzolnier@gmail.com> <57C9024A16AD2D4C97DC78E552063EA309EDE187@orsmsx505.amr.corp.intel.com> <200808222036.m7MKa6bT008897@agluck-lia64.sc.intel.com> <1219439722.3339.89.camel@localhost.localdomain>
In-Reply-To: <1219439722.3339.89.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Robin Holt <holt@sgi.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, "petkovbb@gmail.com" <petkovbb@gmail.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

On 22.08.2008 [16:15:22 -0500], James Bottomley wrote:
> On Fri, 2008-08-22 at 13:36 -0700, Luck, Tony wrote:
> > > How about long instead of int.  int leaves us with the possibility that
> > > something else will expect 8 byte alignment.
> > 
> > How about this?
> > 
> > Align __cmd to ward off kernel unaligned access consoles messages on
> > ia64 (and perhaps make an almost imperceptible performance improvement
> > on other architectures that can handle unaligned access, but do so
> > more slowly than aligned accesses).
> > 
> > Signed-off-by: Tony Luck <tony.luck@intel.com>
> 
> Yuk, really ... you're blowing out the size of a critical structure by
> padding which is unnecessary in 99% of cases.  Commands are supposed to
> be byte streams. Adding extra alignment to generic code because some
> driver has strange rules isn't very well layered.
> 
> Also, these are string out instructions ... They don't have any
> alignment requirements (or they're not supposed to; they're like
> memcpy); they're modelled on the x86 instructions
> 
> What about this as the obvious solution?  It makes the ia64 version of
> this command behave exactly as the x86 version does.
> 
> James

Tested-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

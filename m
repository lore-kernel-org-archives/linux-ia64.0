From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Fri, 22 Aug 2008 21:38:12 +0000
Subject: Re: kernel unaligned accesses on IA64 in IDE
Message-Id: <20080822213812.GC11781@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080819225606.GB22088@us.ibm.com> <20080822164538.GB9047@us.ibm.com> <9ea470500808221029l6bd79c62w4c06d948f962d95c@mail.gmail.com> <200808222036.00536.bzolnier@gmail.com> <57C9024A16AD2D4C97DC78E552063EA309EDE187@orsmsx505.amr.corp.intel.com> <200808222036.m7MKa6bT008897@agluck-lia64.sc.intel.com> <20080822205431.GA5968@gollum.tnic>
In-Reply-To: <20080822205431.GA5968@gollum.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <petkovbb@googlemail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Robin Holt <holt@sgi.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

On 22.08.2008 [22:54:31 +0200], Borislav Petkov wrote:
> On Fri, Aug 22, 2008 at 01:36:06PM -0700, Luck, Tony wrote:
> > > How about long instead of int.  int leaves us with the possibility that
> > > something else will expect 8 byte alignment.
> > 
> > How about this?
> > 
> > Align __cmd to ward off kernel unaligned access consoles messages on
> > ia64 (and perhaps make an almost imperceptible performance improvement
> > on other architectures that can handle unaligned access, but do so
> > more slowly than aligned accesses).
> 
> By the way, i've been wondering, this unaligned access breaking should have
> happened earlier, how did we miss that? Nish, Robin, can you see that in some
> older logs?

I replied about this in a separate sub-thread, but you may not have been
on the direct Cc (though linux-ide should have been).

This all began because I noticed one of my automated test machines had
not successfully booted a kernel in some time. I investigated via
bisection and found that CONFIG_PRINTK_TIME=y was broken on my IA64 box.
With Tony and Peter Z's help, that bug was resolved, but then with the
console working, I noticed these unaligned accesses. Sorry if it seemed
like, from my posting, they were a regression, I did not mean to give
that impression.

They may have been there for some time, but I don't have any logs from
kernels before 2.6.27-rc3, because of the CONFIG_PRINTK_TIME=y breakage
(which was being set by default for this box). I could go back and try
older kernels, if you'd like, but it would take some time.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

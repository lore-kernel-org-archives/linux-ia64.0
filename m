From: david mosberger <dmosberger@gmail.com>
Date: Thu, 01 Sep 2005 19:35:21 +0000
Subject: Re: testing mca/init patch
Message-Id: <ed5aea43050901123563b10726@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
In-Reply-To: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith,

On 8/31/05, Keith Owens <kaos@sgi.com> wrote:
> On Wed, 31 Aug 2005 21:58:58 -0700,
> david mosberger <dmosberger@gmail.com> wrote:

> >- In several places there are checks of the form:
> >
> >+ if ((r12 & -KERNEL_STACK_SIZE) != r13) {
> >
> >  I don't understand why you're doing this.  You should check for (r12
> >- r13) <  KERNEL_STACK_SIZE.  That does the same without relying on
> >alignments (which is something we have been careful to avoid in all
> >other ia64 code).  This should also let you drop the patch to
> >vmlinux.lds.S.
> 
> Paranoia.  I have seen several MCA/INIT events fail because they were
> delivered while the cpu was in PAL/SAL.  r12 and r13 are preserved
> around calls to PAL/SAL, but they are not preserved _within_ PAL/SAL.
> I am trying to verify as much as possible of the original stack before
> updating it, the alignment check is something useful that I can test
> for.

I'm not suggesting to get rid of the test completely, I suggesting to
replace it with a range check of the form:

   (r12 - r13) <  KERNEL_STACK_SIZE

that should be about as tight a check as the original without making
alignment-assumptions.

  --david

-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536

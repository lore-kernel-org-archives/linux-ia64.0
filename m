From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 06 May 2004 23:47:03 +0000
Subject: Re: [PATCH] new ".serialize" gas directive
Message-Id: <16538.52855.525849.78499@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16537.51724.854691.934006@napali.hpl.hp.com>
In-Reply-To: <16537.51724.854691.934006@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 06 May 2004 16:33:36 -0700, Jim Wilson <wilson@specifixinc.com> said:

  Jim> On Wed, 2004-05-05 at 22:15, David Mosberger wrote:
  >> tbit.z p34, p35 = r22, 12	;;
  >> (p34) cmp4.eq p6, p7 = 2, r15
  >> (p35) cmp4.eq p6, p7 = 3, r15	;;
  >> (p6) addl r14 = 1, r0
  >> (p7) mov r14 = r0

  Jim> This one has complications.  If r22 has the NaT bit set, then the result
  Jim> of the tbit.z is to set both p34 and p35 to zero.  Thus p6, p7 are not
  Jim> set, and it is possible that they both could be true if we have no
  Jim> information about them, in which case there is a DV here.

That's a good point.

  Jim> At the moment, neither gcc nor gas really knows anything about
  Jim> NaT bits.

Isn't it true that GCC never produces a NaT on its own and never uses
uninitialized registers?  If so, the code should be fine.  Perhaps GCC
should assert that p34 and p35 are mutually exclusive (effectively
asserting that r22 is not a NaT)?

  >> * config/tc-ia64.c (dot_serialize): Declare.
  >> (dot_serialize): New function.
  >> (md_pseudo_table): Add ".serialize.data" and
  >> ".serialize.instruction" directives.

  Jim> The patch looks fine to me.  I checked it in.

Cool.  Thanks a lot!

	--david

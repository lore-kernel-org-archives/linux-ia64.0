From: Jim Wilson <wilson@specifixinc.com>
Date: Thu, 06 May 2004 23:33:36 +0000
Subject: Re: [PATCH] new ".serialize" gas directive
Message-Id: <1083886417.1078.134.camel@leaf.tuliptree.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16537.51724.854691.934006@napali.hpl.hp.com>
In-Reply-To: <16537.51724.854691.934006@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2004-05-05 at 22:15, David Mosberger wrote:
> 	tbit.z p34, p35 = r22, 12	;;
> 	(p34) cmp4.eq p6, p7 = 2, r15
> 	(p35) cmp4.eq p6, p7 = 3, r15	;;
> 	(p6) addl r14 = 1, r0
> 	(p7) mov r14 = r0

This one has complications.  If r22 has the NaT bit set, then the result
of the tbit.z is to set both p34 and p35 to zero.  Thus p6, p7 are not
set, and it is possible that they both could be true if we have no
information about them, in which case there is a DV here.  If we know
that r22 can not have the NaT bit set, then one and only one of p34 or
p35 will be true in which case at most one of p6 or p7 can be true, in
which case there is no DV.  So resolving this needs extra information
about NaT bits and/or the previous values of p6/p7.  I am not sure if
gas can get this right.  It may not have enough info.  This may also be
a gcc bug, since this code isn't safe if r22 can have a NaT bit set, and
I seriously doubt that gcc checks for this case.

At the moment, neither gcc nor gas really knows anything about NaT bits.

> 	* config/tc-ia64.c (dot_serialize): Declare.
> 	(dot_serialize): New function.
> 	(md_pseudo_table): Add ".serialize.data" and
> 	".serialize.instruction" directives.

The patch looks fine to me.  I checked it in.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com


From: Mario Smarduch <cms063@email.mot.com>
Date: Fri, 26 Sep 2003 15:41:13 +0000
Subject: Re: vhpt_miss handler question?
Message-Id: <marc-linux-ia64-106459084631470@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106458752027199@msgid-missing>
In-Reply-To: <marc-linux-ia64-106458752027199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens wrote:

> On Fri, 26 Sep 2003 09:43:55 -0500,
> Mario Smarduch <cms063@email.mot.com> wrote:
> >Some work I'm doing has taken me to the vhpt_miss
> >handler. I've been looking at  the following snippet just
> >wondering what happens in the case where the present
> >bit is 0 and p10,p11 predicates are not set anotherwords
> >they retain their application values. Would this not
> >cause an errant insertion if either p10 or p11 were
> >true in the application prior to the VHPT handler?
>
> >(p7)    tbit.nz.unc p10,p11=3Dr19,32              // is it an instruction
>
> tbit.xx.unc sets both predicates to 0 if the controlling predicate is
> false.  See the 'else' clause on page 3:229 of Document Number:
> 245319-004 (ia64 Volume 3: Instruction Set Reference).

I understand the unc sets bot predicates to 0. The question
was regarding p7=FAlse, but it appears in that case a TLB
entry with present bit set to 0 may be inserted which appears
to be harmless (other then taking up a TC entry).

Sorry for the noise :)

- mario.


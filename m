From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 26 Sep 2003 15:48:24 +0000
Subject: Re: vhpt_miss handler question?
Message-Id: <marc-linux-ia64-106459138432067@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106458752027199@msgid-missing>
In-Reply-To: <marc-linux-ia64-106458752027199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 26 Sep 2003 09:43:55 -0500, Mario Smarduch <cms063@email.mot.com> said:

  Mario> Some work I'm doing has taken me to the vhpt_miss
  Mario> handler. I've been looking at the following snippet just
  Mario> wondering what happens in the case where the present bit is 0
  Mario> and p10,p11 predicates are not set anotherwords they retain
  Mario> their application values. Would this not cause an errant
  Mario> insertion if either p10 or p11 were true in the application
  Mario> prior to the VHPT handler?

  Mario> (p7) tbit.nz.unc p10,p11=r19,32

Did you miss the .unc qualifier on that instruction?  It causes p10 and
p11 to be set to FALSE when p7 is FALSE.

	--david

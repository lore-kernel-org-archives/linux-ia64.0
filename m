From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 Jul 2004 22:05:37 +0000
Subject: Re: Consistency problem on IPF
Message-Id: <16627.2865.957328.252105@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F2562C.10208@inria.fr>
In-Reply-To: <40F2562C.10208@inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 13 Jul 2004 07:49:35 +1000, Duraid Madina <duraid@octopus.com.au> said:

  Duraid> But no, thanks to Oracle, we are forced to deal with junk
  Duraid> like hugetlbfs..

Huge pages and transparent superpages are mostly orthogonal.  The
former sometimes can be used as a temporary work-around for the
latter, but superpages won't obsolete huge pages (for those problems
where huge pages are suitable, they can't be beat).  This is why huge
pages were accepted into the Linux kernel.  Superpage support is being
worked on separately.

	--david

From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 May 2003 18:56:20 +0000
Subject: Re: [Linux-ia64] run time code generation for IA-64
Message-Id: <marc-linux-ia64-105590723706048@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706033@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706033@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 28 May 2003 00:17:42 +0530 (IST), CH Gowri Kumar <gkumar@csa.iisc.ernet.in> said:

  CH> Hi David,
  >> Where do you have R4 and R5 before using them?

  CH> Did you mean to say that I have to save R4 and R5 before using them?

Yes, of course: "preserved" means you have to save a register before
using it.  On the positive side, it's contents will get preserved
across calls.

  CH> Just wondering why isn't there a standard calling convention on IA-64.
  CH> Something of this sort(if at all to be saved):
  CH> rp has to be saved in loc0
  CH> sp has to be saved in loc1
  CH> gp has to be saved in loc2

That would needlessly constrain code optimization.  For example, on
ia64, it's almost never necessary to save sp.

	--david


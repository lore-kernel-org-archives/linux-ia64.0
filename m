From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 25 Feb 2005 06:11:57 +0000
Subject: RE: [patch]:MC/MT enabling/identification for IA-64
Message-Id: <16926.49581.146535.541299@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 24 Feb 2005 18:22:44 -0800, "Seth, Rohit" <rohit.seth@intel.com> said:

  >> Changing the formatting of /proc/cpuinfo only runs the risk of
  >> existing tools, without benefit to properly written applications.

  Rohit> I hope there are not that many apps that have this
  Rohit> behavior...particularly if they are (/want to be) portable.

I _hope_ the same, but what's the point to even run the risk of
breaking existing apps when there is no real benefit?

  Rohit> I think we should have some consistency (wherever possible)
  Rohit> in /proc/cpuinfo fields across architectures.  This will help
  Rohit> applications writers.  Currently siblings and cpu core fields
  Rohit> are already added for i386 and x86_64.

Hmmh, I don't see a "cpu core id" field in the x86 code.  Am I missing
something?

Printing the same number (# siblings/cores) for each CPU over and over
just seems stupid, especially when instead you can print a useful
value (core id/thread id).

	--david

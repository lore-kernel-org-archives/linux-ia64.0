From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 25 Feb 2005 23:03:16 +0000
Subject: RE: [patch]:MC/MT enabling/identification for IA-64
Message-Id: <16927.44724.74239.726955@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 25 Feb 2005 15:01:07 -0800, "Seth, Rohit" <rohit.seth@intel.com> said:

  >>  Yeah, I guess "MAX(thread_id) + 1" does count as a
  >> "calculation".  And I thought computers where good at that... ;-)

  Rohit> Siblings have no direct relationship with thread_id.
  Rohit> Tids(threads ids) are not guranteed to be contiguous.

Ah, that's a good point.

Thanks,

	--david

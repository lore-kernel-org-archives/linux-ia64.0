From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 25 Feb 2005 22:46:46 +0000
Subject: RE: [patch]:MC/MT enabling/identification for IA-64
Message-Id: <16927.43734.546795.91007@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 25 Feb 2005 13:15:05 -0800, "Seth, Rohit" <rohit.seth@intel.com> said:

  Rohit> For pinning a task (or set of tasks) to same core or multiple
  Rohit> cores, you only need package id and core id.  The thread
  Rohit> information is really not required.  Right?

Yeah, that's true.  At least I can't come up with a good reason of
wanting to know which thread exactly you're running on.  Having said
that, from a user-perspective, looking at two entries in /proc/cpuinfo
and seeing that the socket id/core id are the same and only the thread
ids are different probably would give me more of a warm and fuzzy
feeling.

  Rohit> AFAIK, an easy way for apps (for licensing etc.) to find out
  Rohit> if and how many LEUs are present without doing any other
  Rohit> calculation.

Yeah, I guess "MAX(thread_id) + 1" does count as a "calculation".  And
I thought computers where good at that... ;-)

	--david

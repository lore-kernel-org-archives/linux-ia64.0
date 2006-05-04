From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 04 May 2006 16:58:04 +0000
Subject: RE: [RFC 2/3] LVHPT - Setup LVHPT
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F06680039@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060502052557.8990.87273.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20060502052557.8990.87273.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ian Wienand <ianw@gelato.unsw.edu.au>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org

> Being relatively inexperienced, all this dynamic patching (SMP, page
> table, this) scares me in that what is executing diverges from what
> appears to be in source code, making difficult things even more
> difficult to debug.  Is there consensus that a long term goal should
> be that short and long formats should be dynamically selectable?

I wouldn't rule anything out until I see what can be done, and how
maintainable the code to do it is.  Perhaps someone will come up with
the ultimate in dynamic selection and use long format for some processes,
and short format for others (and thus get around the objections that
some workloads perform less well with long format).

-Tony

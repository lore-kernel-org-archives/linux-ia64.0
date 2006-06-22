From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 22 Jun 2006 17:34:06 +0000
Subject: RE: patches added to release/test trees
Message-Id: <617E1C2C70743745A92448908E030B2A22F4A6@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
In-Reply-To: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> May 16.  The Makefile is for 2.6.17-rc5.  Is there a propogation delay
> on your git updates before they hit git.kernel.org?

Yes, there is a delay.  I update to a backend system at kernel.org which
regularly rsyncs the data to the two front-end systems: {www1,www2}.kernel.org
The delay varies depending on load on the systems, and the overall internet
weather.  It can be as short as a couple of minutes.  When it goes above
a couple of hours it indicates there is a problem.  The updates to the
two front-end systems are independent ... you can force access to one
or the other by using the www1, www2 names to see whether one managed to
get the update.

> BTW, is there any reason that the aegl git tree has no tags?

I haven't thought of any useful way to use tags.  But perhaps it's
becuase I mostly think of my GIT trees as conduits to Linus/Andrew.
If you have suggestions on how I can make my trees more useful to
you by tagging things, then let me know.

-Tony

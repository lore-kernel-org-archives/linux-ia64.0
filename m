From: Ravi g <ritanium@yahoo.com>
Date: Sat, 02 Aug 2003 21:55:27 +0000
Subject: How do acq and rel work?
Message-Id: <marc-linux-ia64-105986138027457@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi everybody,
          Im just fiddling with critical regions in
assembly. From what i have seen from intel
documentation you can make a critical region by
enclosing it between .acq and .rel instructions.
          But it looks like with these instructions
you have to set a flag as a side-effect and check for
the flag status every time you want to enter the
critical region. Is that how they work? or are there
other ways of doing it.
And finally can somebody point out good links to
implementing semaphores and like in itanium.
-Ravi

__________________________________
Do you Yahoo!?
Yahoo! SiteBuilder - Free, easy-to-use web site design software
http://sitebuilder.yahoo.com

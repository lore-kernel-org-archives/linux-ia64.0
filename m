From: "Wichmann, Mats D" <mats.d.wichmann@intel.com>
Date: Wed, 15 Jan 2003 20:14:50 +0000
Subject: [Linux-ia64] UML support for Itanium?
Message-Id: <marc-linux-ia64-105590709805689@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've been meaning to ask the question, but
never seem to get around to it.


Now that the UML "support" bits are in Linus'
2.5 tree, isn't it time to get more serious
about UML for Itanium?

Every now and then it seems someone pops up
who takes a whack at it, and then after a
while there's no further word....

UML (despite the acronym overloading) makes
a pretty handy test environment, you can
sandbox all sort of experiments that might
be somewhat intrusive otherwise.  For example,
I use it on ia32 to run a restricted
(LSB-only) environment for application 
conformance testing.

Folks have developed ways to build/test
driver code without rebuilding/rebooting
the host kernel, as a jail for web applications,
and so on.

Thoughts?






From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 27 Feb 2001 05:13:51 +0000
Subject: Re: [Linux-ia64] gcj build on Itanium
Message-Id: <marc-linux-ia64-105590693005215@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005213@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005213@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I attempted to build gcc (roughly CVS version, as of about a week ago),

You should use the gcc3 branch instead of the gcc trunk.  Potentially unsafe
patches were deferred the last few months in preparation for gcc3 release work,
and now that we have the release branch, those patches are going onto the
trunk.  Thus the release branch will be much more stable than the trunk.
Also, it is more important to get the release branch working than the trunk.
The branch name is gcc-3_0-branch.

>  Is -fPIC different from -fpic on Itanium?

No.

That is about all I can do at the moment.  I'm at IDF this week, and hence
not able to do much real work.  I may be able to provide assistance on some
of the problems that are IA-64 back-end specific after IDF ends.

Jim


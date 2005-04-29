From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Apr 2005 09:41:26 +0000
Subject: Re: BK to GIT migration status for ia64
Message-Id: <17010.326.499746.341125@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F035ECFEA@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F035ECFEA@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 28 Apr 2005 12:19:49 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> It's been a hectic month (well, not even a month ... this
  Tony> is only day 24 of the great migration :)

  Tony> I've set up a pair of GIT trees on kernel.org for ia64 to
  Tony> keep track of changes.

  Tony> 1) rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git

  Tony> This is the "to-linus" tree.  Anything commited here is queued to go
  Tony> into Linus' tree next time he does a pull from me.  Some obviously
  Tony> correct (to me) patches will go directly into this tree, but most
  Tony> patches will spend time in the test tree.

  Tony> 2) rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/test-2.6.git

  Tony> This is the "to-andrew" tree.  Andrew has a script to pull
  Tony> automatically from here, so changes in this tree will usually
  Tony> end up in the next "-mm" patch.

Looking good so far.  Of course, I'm still waiting to see what happens
when attempting a first non-trivial merge...

  Tony> I'm not going to play games renaming these trees each release (pauses
  Tony> to wait for cheering to die down) this didn't really work for me the
  Tony> way it did for Len (from whom I stole the idea) because my workflow
  Tony> isn't quite the same.

Excellent.  Might have to wait for a _long_ while for the applause to
die down... ;-)

	--david

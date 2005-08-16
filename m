From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 16 Aug 2005 22:00:38 +0000
Subject: change to the ia64 GIT trees
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F042945E9@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now that GIT is smarter, and I'm more aware of what it can do
(and how to make it do it), I'm making a small change to how
I export GIT trees on kernel.org.

Instead of having separate trees for test and release, there
is now just one tree which contains "test" and "release" branches.
[or there will be soon when my deletion of the old test tree
is reflected on the kernel.org mirrors].

You can pull each of the branches separately with:

 $ git pull rsync://rsync.kernel.org/..../aegl/linux-2.6 test
or
 $ git pull rsync://rsync.kernel.org/..../aegl/linux-2.6 release

I wrote a "howto" for GIT about using branches as a Linux
subsystem maintainer that was included in the GIT sources
yesterday.  You can read a copy at http://tinyurl.com/d57dc

-Tony

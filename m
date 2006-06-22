From: Keith Owens <kaos@sgi.com>
Date: Thu, 22 Jun 2006 23:28:49 +0000
Subject: Re: patches added to release/test trees
Message-Id: <1539.1151018929@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
In-Reply-To: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" (on Thu, 22 Jun 2006 10:34:06 -0700) wrote:
>> BTW, is there any reason that the aegl git tree has no tags?
>
>I haven't thought of any useful way to use tags.  But perhaps it's
>becuase I mostly think of my GIT trees as conduits to Linus/Andrew.
>If you have suggestions on how I can make my trees more useful to
>you by tagging things, then let me know.

Not adding your own tags, but Linus's tags are missing from the ia64
tree.  For some reason, just copying .git/refs/tags from the torvalds
git tree does not work, git-branch complains about invalid objects.  I
thought that tags were portable between trees with common ancestors.

  git-clone .../git/torvalds/linux-2.6.git linux-2.6
  git-clone .../git/aegl/linux-2.6.git linux-2.6-ia64
  cp -a linux-2.6/.git/refs/tags/* linux-2.6-ia64/.git/refs/tags/
  cd linux-2.6-ia64
  git-branch
  error: refs/tags/v2.6.11 does not point to a valid commit object!
  error: refs/tags/v2.6.11-tree does not point to a valid commit object!
  ...
  error: refs/tags/v2.6.17-rc5 does not point to a valid commit object!
  error: refs/tags/v2.6.17-rc6 does not point to a valid commit object!
    origin
    * release
    test



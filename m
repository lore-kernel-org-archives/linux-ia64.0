From: Keith Owens <kaos@sgi.com>
Date: Sat, 24 Jun 2006 08:10:12 +0000
Subject: Re: patches added to release/test trees
Message-Id: <23024.1151136612@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
In-Reply-To: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" (on Fri, 23 Jun 2006 10:08:22 -0700) wrote:
>> That makes sense.  But why is the ia64 git tree missing the Linus
>> objects and tags in the first place?
>
>"tags" is a bit ambiguous here, there are two possible things that
>you might be talking about when you say "tag" w.r.t. a GIT tree.
>
>1) A file in .git/refs/tags/ that contains the SHA1 of a git object.

Them.

>2) A git object of type "tag".
>
>The files in .git/refs/tags refer to GIT tag objects.  Usually a
>tag object is a pointer to a commit object ... but they can point
>at anything (the v2.6.11 tag object points to a "tree").
>
>Things get more complex from here.  My kernel.org tree contains none
>of the .git/refs/tags files (because I "git push" the heads of the
>release/test branches up from my local tree, anf this won't copy any
>tags files up ... even though they are all in my local tree from
>my "git fetch linus" pulls from Linus).

Could you push the refs/tags from your tree as well?  Many of the git
trees on kernel.org have copies of Linus's tags, which makes it a bit
easier to cross reference.


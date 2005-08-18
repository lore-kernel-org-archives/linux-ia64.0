From: Mark Maule <maule@sgi.com>
Date: Thu, 18 Aug 2005 13:14:15 +0000
Subject: Re: change to the ia64 GIT trees
Message-Id: <20050818131415.GJ4191@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F042945E9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F042945E9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Aug 17, 2005 at 10:05:51PM -0700, Luck, Tony wrote:
> >> Instead of having separate trees for test and release, there
> >> is now just one tree which contains "test" and "release" branches.
> >
> >Does anyone know how one gets to these using cogito?  Or maybe I
> >should just not use cogito?
> 
> I started off using cogito in the early days of GIT, but I didn't
> keep up with its development ... so I don't know how to pull these
> with cogito.  This might be a case where pure GIT and cogito play
> nice together ... so you could try a "git pull" to get each branch
> and see what cogito thinks of it.  A git branch is just an extra
> file in .git/refs/heads/ with the SHA1 of the head of that branch.

I'm no git/cogito expert, but the following worked for me to get a test
branch snapshot:

cg-clone rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git#test test

This gets the correct source, but the branch names are misleading to me:

attica$ cg-branch-ls
origin  rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git#test

Mark

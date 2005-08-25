From: Martin Hicks <mort@bork.org>
Date: Thu, 25 Aug 2005 13:16:39 +0000
Subject: Re: change to the ia64 GIT trees
Message-Id: <20050825131639.GV13449@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F042945E9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F042945E9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Thu, Aug 18, 2005 at 08:14:15AM -0500, Mark Maule wrote:
> 
> I'm no git/cogito expert, but the following worked for me to get a test
> branch snapshot:
> 
> cg-clone rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git#test test
> 
> This gets the correct source, but the branch names are misleading to me:
> 
> attica$ cg-branch-ls
> origin  rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git#test

Clone the main repository and cg-branch-add the test branch?

mh

-- 
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE

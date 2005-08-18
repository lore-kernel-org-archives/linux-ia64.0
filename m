From: Andrew Morton <akpm@osdl.org>
Date: Thu, 18 Aug 2005 04:29:48 +0000
Subject: Re: change to the ia64 GIT trees
Message-Id: <20050817212948.28f1fa4e.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F042945E9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F042945E9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> wrote:
>
> Now that GIT is smarter, and I'm more aware of what it can do
> (and how to make it do it), I'm making a small change to how
> I export GIT trees on kernel.org.
> 
> Instead of having separate trees for test and release, there
> is now just one tree which contains "test" and "release" branches.
> [or there will be soon when my deletion of the old test tree
> is reflected on the kernel.org mirrors].
> 
> You can pull each of the branches separately with:
> 
>  $ git pull rsync://rsync.kernel.org/..../aegl/linux-2.6 test
> or
>  $ git pull rsync://rsync.kernel.org/..../aegl/linux-2.6 release

Methinks these are supposed to be .../linux-2.6.git, yes?

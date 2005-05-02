From: Keith Owens <kaos@sgi.com>
Date: Mon, 02 May 2005 12:59:14 +0000
Subject: Re: BK to GIT migration status for ia64
Message-Id: <29944.1115038754@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F035ECFEA@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F035ECFEA@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2 May 2005 04:47:09 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Sun, 01 May 2005 14:19:28 +1000, Keith Owens <kaos@sgi.com> said:
>
>  Keith> On Thu, 28 Apr 2005 12:19:49 -0700, "Luck, Tony"
>  Keith> <tony.luck@intel.com> wrote:
>  >> 1)
>  >> rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
>  >> 2)
>  >> rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/test-2.6.git
>
>  Keith> Neither tree contains a refs or heads directory.  Other git
>  Keith> trees like linux and davem have these directories.  cogito
>  Keith> cg-clone and cg-update expect to find refs and heads.
>
>I cloned the test-2.6 tree last Friday (with cogito) without any
>problems.  I do see the "refs" and "heads" directories.  Not that it
>helps explain your problem, but just an additional data-point.

Those directories are created locally by the clone process, but they do
not exist in the kernel.org trees.  I'm not sure if they are needed or
not, almost every other git tree on kernel.org has them.


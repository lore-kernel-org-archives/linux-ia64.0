From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 27 May 2008 01:46:28 +0000
Subject: Re: [PATCH 00/17] ia64/pv_ops take 6
Message-Id: <20080527014628.GB23946%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12112028241775-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12112028241775-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 20, 2008 at 02:59:49PM -0700, Luck, Tony wrote:
> > Hi. This patchset implements ia64/pv_ops support which is the
> > framework for virtualization support.
> > Changes from take 5 are rebased to Linux 2.6.26-rc3,
> > bug fix ivt.S paravirtualization and multi entry point support.
> > I believe these patches can be applied to the linux ia64 repository.
> 
> Ok.  This series of 17 patches applied, and I can boot the
> resulting kernel as a native binary.  I'll run it for another
> day or two, if nothinstrange happens I'll add these to my
> "test" tree so they'll go to -mm and linux-next for more general
> testing.

Hello Tony. Thank you for testing.

What was the result?
No patch has been committed to
git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git#test
Did anything go wrong?

-- 
yamahata

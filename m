From: Andrew Morton <akpm@osdl.org>
Date: Sat, 04 Feb 2006 04:27:42 +0000
Subject: Re: Altix SN2 2.6.16-rc1-mm5 build breakage (was:  msi support)
Message-Id: <20060203202742.1e514fcc.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060119194647.12213.44658.14543@lnx-maule.americas.sgi.com>
	<20060119194702.12213.16524.93275@lnx-maule.americas.sgi.com>
	<20060203201441.194be500.pj@sgi.com>
	<20060203202531.27d685fa.akpm@osdl.org>
In-Reply-To: <20060203202531.27d685fa.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: pj@sgi.com, maule@sgi.com, linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, gregkh@suse.de

Andrew Morton <akpm@osdl.org> wrote:
>
> So it
>  looks like you've found a fix for a patch which isn't actually in -mm any
>  more.  I sent that fix to Greg the other day.

Actually, gregkh-pci-altix-msi-support-git-ia64-fix.patch fix`es
git-ia64.patch when gregkh-pci-altix-msi-support.patch is also applied, so
it's not presently useful to either Greg or Tony.  I'll take care of it,
somehow..


From: Andrew Morton <akpm@osdl.org>
Date: Wed, 06 Apr 2005 21:56:34 +0000
Subject: Re: tiger_defconfig build fails for 2.6.12-rc2-mm1
Message-Id: <20050406145634.38ec557a.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405165047.A21553@unix-os.sc.intel.com>
In-Reply-To: <20050405165047.A21553@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rajesh Shah <rajesh.shah@intel.com> wrote:
>
> On Tue, Apr 05, 2005 at 06:50:10PM -0700, Andrew Morton wrote:
> > 
> > hm, I built and booted that kernel on my tiger box.  Could you send me the
> > actual .config please?
> 
> Here's my actual .config. I should have also mentioned that the
> kernel I built after reverting those 2 patches booted fine
> on my tiger system.

I don't see why bk-acpi-alpha-build-fix.patch needed to be reverted?

From: Andrew Morton <akpm@osdl.org>
Date: Wed, 06 Apr 2005 01:50:10 +0000
Subject: Re: tiger_defconfig build fails for 2.6.12-rc2-mm1
Message-Id: <20050405185010.72b92538.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405165047.A21553@unix-os.sc.intel.com>
In-Reply-To: <20050405165047.A21553@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rajesh Shah <rajesh.shah@intel.com> wrote:
>
> My ia64 kernel build for 2.6.12-rc2-mm1 failed today for a .config
> generated from tiger_defconfig. I ran into 2 separate compile
> failures. Reverting 
> add-a-clear_pages-function-to-clear-pages-of-higher.patch
> fixed the first compile error, reverting 
> bk-acpi-alpha-build-fix.patch
> fixed the second error. Since I was really just trying to get a
> booting kernel, I haven't (yet) chased this any further to 
> identify proper fixes. FYI, in case others are trying to work
> around these failures too.
> 

hm, I built and booted that kernel on my tiger box.  Could you send me the
actual .config please?

From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 31 Aug 2005 21:45:38 +0000
Subject: RE: [PATCH] Reserve syscall number for sys_migrate_pages
Message-Id: <Pine.LNX.4.62.0508311443030.29514@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 31 Aug 2005, Luck, Tony wrote:

> >There is general agreement on sys_migrate_pages. See the linux-mm 
> >archives.
> 
> So send the patch to Andrew Morton, and he'll coordinate adding
> it to all the architectures.

sys_migrate_pages is going to be available first on ia64. And it will take 
awhile to get the sequence of memory hotplug and page migration 
patches through this. Without this patchset the number for the system call 
may change multiple times and require repeated changes to the libraries, 
tools and patches.


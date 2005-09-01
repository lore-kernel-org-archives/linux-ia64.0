From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 01 Sep 2005 00:06:17 +0000
Subject: RE: [PATCH] Reserve syscall number for sys_migrate_pages
Message-Id: <Pine.LNX.4.62.0508311701030.30361@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 31 Aug 2005, Luck, Tony wrote:

> 
> >There is general agreement on sys_migrate_pages. See the linux-mm 
> >archives.
> 
> Can you provide pointers to threads with this general agreement.
> 
> My searches of the archive aren't very conclusive. I found some
> discussions between Andi Kleen and yourself, but at that point
> (mid July) you seemed to be arguing _against_ the current suggestions
> for migration.

The discussions took place between Andi and Ray over the first half of 
2005. The approach that I advocated recently was not acceptable it seems 
and thus I am simply continuing to push and improve on the earlier 
approach by Ray that was negotiated and agreed upon by various parties. 
These patches are also currently being tested by others.

http://marc.theaimsgroup.com/?l=linux-mm&m2025806616190&w=2

http://marc.theaimsgroup.com/?l=linux-mm&m1945947315561&w=2


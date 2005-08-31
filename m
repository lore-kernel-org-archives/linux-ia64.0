From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 31 Aug 2005 21:33:27 +0000
Subject: RE: [PATCH] Reserve syscall number for sys_migrate_pages
Message-Id: <Pine.LNX.4.62.0508311432500.29430@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 31 Aug 2005, Luck, Tony wrote:

> Many people want to add new system calls, not all of them succeed.
> Allocation of system call numbers can wait until there is general
> agreement that the call is going to be accepted.

There is general agreement on sys_migrate_pages. See the linux-mm 
archives.


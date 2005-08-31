From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 31 Aug 2005 21:21:10 +0000
Subject: RE: [PATCH] Reserve syscall number for sys_migrate_pages
Message-Id: <Pine.LNX.4.62.0508311416340.29108@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 31 Aug 2005, Luck, Tony wrote:

> >+#define __NR_sys_migrate_pages		1280
> 
> The tradition is to leave out-of-tree patches to step to
> a new number when new syscalls usurp the one they thought
> they were going to get.

There are already a couple of syscall reservations in entry.S for kexec 
and vserver. What makes these so special?

> New syscalls are not added very often, so this isn't really
> much effort (compared with maintaining all the code to implement
> the new syscall).

Yes but its easier to simply replace the sys_ni_syscall with the function 
call when it finally hits mainline. If the number stays the same then the user
space source using this function calls do not have to be redone and work 
on library maintenance can proceed concurrently.

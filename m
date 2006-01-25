From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 25 Jan 2006 09:33:10 +0000
Subject: RE: Optimize task_thread_info()
Message-Id: <200601250933.k0P9XAg22783@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601250234.k0P2Y0g18230@unix-os.sc.intel.com>
In-Reply-To: <200601250234.k0P2Y0g18230@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Chen, Kenneth wrote on Tuesday, January 24, 2006 6:34 PM
> Kernel scheduler uses thread_info.cpu heavily, task_cpu(p) is use just
> about in every hot scheduler functions.  Since thread_info structure
> always has constant offset from task_struct, access to member variable
> of thread_info can be as simple as adding a constant to task_struct
> pointer.  Optimize ia64 task_thread_info() to use constant offset. This
> saves a memory indirection whenever thread_info structure is used.

Nevermind, someone beat me to it by stunning 12 days!!

http://www.kernel.org/git/gitweb.cgi?p=3Dlinux/kernel/git/torvalds/linux-2.=
6.git;a=3Dcommit;h=AB03591db110e8d195d381a68692eb37da981cdf

[PATCH] ia64: task_thread_info()

on ia64 thread_info is at the constant offset from task_struct and stack
is embedded into the same beast.  Set __HAVE_THREAD_FUNCTIONS, made
task_thread_info() just add a constant.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Linus Torvalds <torvalds@osdl.org>


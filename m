From: James E Wilson <wilson@tuliptree.org>
Date: Wed, 21 Sep 2005 21:47:40 +0000
Subject: Re: ia64 dispersal analysis capability
Message-Id: <1127339260.26485.57.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050921182143.GA30873@sgi.com>
In-Reply-To: <20050921182143.GA30873@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-09-21 at 11:23, Jack Steiner wrote:
> In 2002, Gary Hade posted a patch to binutils that added dispersal
> analysis to the output of objdump. Does anyone know what happened to
> the patch? Is there another tool that provides the same information?

As for the "other tool" part of this question, you can get some info
from gcc by using -fsched-verbose=2 -fdump-rtl-sched1 -fdump-rtl-mach.
This will give you a lot of info about what the gcc instruction
scheduler did, but the interesting stuff is in the  "--> " lines in the
*.mach file.  This will give you lines like
;;        1--> 11   r14=[r14]                          :2_M_only_um01
which gives you the cycle number (1), the gcc internal instruction
number (11), an abstract representation of what the instruction does
(r14=[r14]), and the scheduling unit info (2_M_only_um01).  The 2 stands
for Itanium2.  The M stands for a memory unit.  The only_um01 means it
must be scheduled to one of the first two memory units.

This info is to help gcc developers debug instruction scheduler related
problems, and isn't really meant to be easily readable by end users, but
you may find it useful.

Actually, the above command only works for gcc-4.  For gcc-3, just use
-fsched-verbose=2 -da and ignore the non-scheduler related dump files.



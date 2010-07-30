From: Hugh Dickins <hughd@google.com>
Date: Fri, 30 Jul 2010 02:01:56 +0000
Subject: Re: ia64 hang/mca running gdb 'make check'
Message-Id: <alpine.DEB.1.00.1007291853450.4466@tigran.mtv.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100720173512.GF26783@ldl.fc.hp.com> <20100721105136.9d4440de.kamezawa.hiroyu@jp.fujitsu.com> <20100721030629.GA9987@lackof.org> <alpine.DEB.1.00.1007202106420.12760@tigran.mtv.corp.google.com> <20100727071914.GB22945@lackof.org>
 <20100727180330.b6ecba7f.kamezawa.hiroyu@jp.fujitsu.com> <20100727144326.GC22945@lackof.org> <alpine.DEB.1.00.1007282031130.4207@tigran.mtv.corp.google.com> <20100729192216.GF20265@lackof.org>
In-Reply-To: <20100729192216.GF20265@lackof.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dann frazier <dannf@debian.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Ralf Baechle <ralf@linux-mips.org>

On Thu, 29 Jul 2010, dann frazier wrote:
> On Wed, Jul 28, 2010 at 08:50:18PM -0700, Hugh Dickins wrote:
> >=20
> > Let's note that gdb's gcore is building up its own version of a
> > coredump, not going through the get_dump_page() code I was wondering
> > about.  If I read gcore correctly (possibly not!), it will be reading
> > selected areas from /proc/<pid>/mem i.e. using access_process_vm().
>=20
> This appears to be correct. I was able to collect the following
> stacktrace using INIT:
>=20
> [ 2535.074197] Backtrace of pid 4605 (gdb)
> [ 2535.074197]=20
> [ 2535.074197] Call Trace:
> [ 2535.074197]  [<a00000010000bb00>] ia64_native_leave_kernel+0x0/0x270
> [ 2535.074197]                                 sp=E000004081c77c40 bsp=E0=
00004081c71018
> [ 2535.074197]  [<a000000100334720>] __copy_user+0x160/0x960
> [ 2535.074197]                                 sp=E000004081c77e10 bsp=E0=
00004081c71018
> [ 2535.074197]  [<a000000100176b00>] access_process_vm+0x2c0/0x380
> [ 2535.074197]                                 sp=E000004081c77e10 bsp=E0=
00004081c70f60

Thanks a lot, dann.  But it was the [vdso] line in foo's /proc/<pid>/maps
which you sent me privately, that set me thinking on the right track.
Here's what I believe is the appropriate patch: please give it a try
and let us know...

[PATCH] mm: fix ia64 crash when gcore reads gate area

Debian's ia64 autobuilders have been seeing kernel freeze or reboot
when running the gdb testsuite (Debian bug 588574): dannf bisected to
2.6.32 62eede62dafb4a6633eae7ffbeb34c60dba5e7b1 "mm: ZERO_PAGE without
PTE_SPECIAL"; and reproduced it with gdb's gcore on a simple target.

I'd missed updating the gate_vma handling in __get_user_pages(): that
happens to use vm_normal_page() (nowadays failing on the zero page),
yet reported success even when it failed to get a page - boom when
access_process_vm() tried to copy that to its intermediate buffer.

Fix this, resisting cleanups: in particular, leave it for now reporting
success when not asked to get any pages - very probably safe to change,
but let's not risk it without testing exposure.

Why did ia64 crash with 16kB pages, but succeed with 64kB pages?
Because setup_gate() pads each 64kB of its gate area with zero pages.

Reported-by: Andreas Barth <aba@not.so.argh.org>
Bisected-by: dann frazier <dannf@debian.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org
---

 mm/memory.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

--- 2.6.35-rc6/mm/memory.c	2010-05-30 17:58:57.000000000 -0700
+++ linux/mm/memory.c	2010-07-29 17:57:29.000000000 -0700
@@ -1394,10 +1394,20 @@ int __get_user_pages(struct task_struct
 				return i ? : -EFAULT;
 			}
 			if (pages) {
-				struct page *page =3D vm_normal_page(gate_vma, start, *pte);
+				struct page *page;
+
+				page =3D vm_normal_page(gate_vma, start, *pte);
+				if (!page) {
+					if (!(gup_flags & FOLL_DUMP) &&
+					     is_zero_pfn(pte_pfn(*pte)))
+						page =3D pte_page(*pte);
+					else {
+						pte_unmap(pte);
+						return i ? : -EFAULT;
+					}
+				}
 				pages[i] =3D page;
-				if (page)
-					get_page(page);
+				get_page(page);
 			}
 			pte_unmap(pte);
 			if (vmas)

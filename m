From: "H . J . Lu" <hjl@valinux.com>
Date: Wed, 10 Jan 2001 01:35:26 +0000
Subject: Re: [Linux-ia64] [PATCH] Fix for kernel DRM build
Message-Id: <marc-linux-ia64-105590678205909@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205902@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205902@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 09, 2001 at 02:46:27PM -0800, David Mosberger wrote:
> This should be labeled a toolchain issue.  The problem occurs whenever
> someone is building and linking against an "empty" archive.  The same
> problem occurred in the "media/" subdirectory but I did a quick hack to
> work around the problem.
> 

This patch seems to work for me.


H.J.
---
2001-01-09  H.J. Lu <hjl@valinux.com>

	* elf64-ia64.c (elf64_ia64_merge_private_bfd_data): Don't
	merge with the empty input file.

--- bfd/elf64-ia64.c.empty	Tue Jan  9 17:06:55 2001
+++ bfd/elf64-ia64.c	Tue Jan  9 17:28:42 2001
@@ -3973,6 +3973,10 @@ elf64_ia64_merge_private_bfd_data (ibfd,
       || bfd_get_flavour (obfd) != bfd_target_elf_flavour)
     return false;
 
+  /* If the input file has no data, we have nothing to merge.  */
+  if (ibfd->sections = NULL)
+    return true;
+
   in_flags  = elf_elfheader (ibfd)->e_flags;
   out_flags = elf_elfheader (obfd)->e_flags;
 


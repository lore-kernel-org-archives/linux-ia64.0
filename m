From: Kees Cook <keescook@chromium.org>
Date: Mon, 28 Feb 2022 19:46:13 +0000
Subject: [PATCH] binfmt_elf: Avoid total_mapping_size for ET_EXEC
Message-Id: <20220228194613.1149432-1-keescook@chromium.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: matoro <matoro_mailinglist_kernel@matoro.tk>
Cc: Kees Cook <keescook@chromium.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Eric Biederman <ebiederm@xmission.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, stable@vger.kernel.org, Thorsten Leemhuis <regressions@leemhuis.info>, Anthony Yznaga <anthony.yznaga@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, regressions@lists.linux.dev, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-hardening@vger.kernel.org

Partially revert commit 5f501d555653 ("binfmt_elf: reintroduce using
MAP_FIXED_NOREPLACE").

At least ia64 has ET_EXEC PT_LOAD segments that are not virtual-address
contiguous (but _are_ file-offset contiguous). This would result in
giant mapping attempts to cover the entire span, including the virtual
address range hole. Disable total_mapping_size for ET_EXEC, which
reduces the MAP_FIXED_NOREPLACE coverage to only the first PT_LOAD:

$ readelf -lW /usr/bin/gcc
...
Program Headers:
  Type Offset   VirtAddr           PhysAddr           FileSiz  MemSiz   ...
...
  LOAD 0x000000 0x4000000000000000 0x4000000000000000 0x00b5a0 0x00b5a0 ...
  LOAD 0x00b5a0 0x600000000000b5a0 0x600000000000b5a0 0x0005ac 0x000710 ...
...
       ^^^^^^^^ ^^^^^^^^^^^^^^^^^^                    ^^^^^^^^ ^^^^^^^^

File offset range     : 0x000000-0x00bb4c
			0x00bb4c bytes

Virtual address range : 0x4000000000000000-0x600000000000bcb0
			0x200000000000bcb0 bytes

Ironically, this is the reverse of the problem that originally caused
problems with ET_EXEC and MAP_FIXED_NOREPLACE: overlaps. This problem is
with holes. Future work could restore full coverage if load_elf_binary()
were to perform mappings in a separate phase from the loading (where
it could resolve both overlaps and holes).

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Eric Biederman <ebiederm@xmission.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org
Reported-by: matoro <matoro_mailinglist_kernel@matoro.tk>
Reported-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Fixes: 5f501d555653 ("binfmt_elf: reintroduce using MAP_FIXED_NOREPLACE")
Link: https://lore.kernel.org/r/a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info
Cc: stable@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
matoro (or anyone else) can you please test this?
---
 fs/binfmt_elf.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 9bea703ed1c2..474b44032c65 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1136,14 +1136,25 @@ static int load_elf_binary(struct linux_binprm *bprm)
 			 * is then page aligned.
 			 */
 			load_bias = ELF_PAGESTART(load_bias - vaddr);
-		}
 
-		/*
-		 * Calculate the entire size of the ELF mapping (total_size).
-		 * (Note that first_pt_load is set to false later once the
-		 * initial mapping is performed.)
-		 */
-		if (first_pt_load) {
+			/*
+			 * Calculate the entire size of the ELF mapping
+			 * (total_size), used for the initial mapping,
+			 * due to first_pt_load which is set to false later
+			 * once the initial mapping is performed.
+			 *
+			 * Note that this is only sensible when the LOAD
+			 * segments are contiguous (or overlapping). If
+			 * used for LOADs that are far apart, this would
+			 * cause the holes between LOADs to be mapped,
+			 * running the risk of having the mapping fail,
+			 * as it would be larger than the ELF file itself.
+			 *
+			 * As a result, only ET_DYN does this, since
+			 * some ET_EXEC (e.g. ia64) may have virtual
+			 * memory holes between LOADs.
+			 *
+			 */
 			total_size = total_mapping_size(elf_phdata,
 							elf_ex->e_phnum);
 			if (!total_size) {
-- 
2.32.0

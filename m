From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 19 Jul 2005 01:26:43 +0000
Subject: [PATCH] Fix uninitalised values in efi_memmap_walk
Message-Id: <20050719012643.GD10518@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix

arch/ia64/kernel/efi.c: In function 'efi_memmap_walk':
arch/ia64/kernel/efi.c:306: warning: 'prev.start' may be used uninitialized in this function
arch/ia64/kernel/efi.c:306: warning: 'prev.end' may be used uninitialized in this function

--

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -303,7 +303,7 @@ efi_memmap_walk (efi_freemem_callback_t 
 	struct range {
 		u64 start;
 		u64 end;
-	} prev, curr;
+	} prev = {0}, curr = {0};
 	void *efi_map_start, *efi_map_end, *p, *q;
 	efi_memory_desc_t *md, *check_md;
 	u64 efi_desc_size, start, end, granule_addr, last_granule_addr, first_non_wb_addr = 0;

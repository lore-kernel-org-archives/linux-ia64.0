From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 20 Nov 2008 00:50:28 +0000
Subject: ia64: linux-next allmodconfig
Message-Id: <20081119165028.ed07b078.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


arch/ia64/kernel/built-in.o(.text+0x4a22): In function `efi_initialize_iomem_resources':
: undefined reference to `__ia64_save_stack_nonlocal'
arch/ia64/kernel/built-in.o(.text+0x16262): In function `pfm_context_create':
: undefined reference to `__ia64_save_stack_nonlocal'
arch/ia64/kernel/built-in.o(.text+0x238a2): In function `sys_perfmonctl':
: undefined reference to `__ia64_save_stack_nonlocal'
arch/ia64/kernel/built-in.o(.text+0x466c2): In function `dup_state_stack':
: undefined reference to `__ia64_save_stack_nonlocal'
arch/ia64/kernel/built-in.o(.text+0x46cf2): In function `desc_prologue':
: undefined reference to `__ia64_save_stack_nonlocal'
arch/ia64/kernel/built-in.o(.text+0x49752): more undefined references to `__ia64_save_stack_nonlocal' follow

Whatever caused this is fairly well hidden from `grep'..

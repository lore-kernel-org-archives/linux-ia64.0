From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 21 Aug 2008 06:35:26 +0000
Subject: linux-next: ia64 allmodconfig
Message-Id: <20080820233526.14c44ea6.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/kernel/built-in.o(.text+0x4862): In function `efi_initialize_iomem_resources':
: undefined reference to `__ia64_save_stack_nonlocal'
arch/ia64/kernel/built-in.o(.text+0x12a92): In function `pfm_context_create':
: undefined reference to `__ia64_save_stack_nonlocal'
arch/ia64/kernel/built-in.o(.text+0x1bc02): In function `sys_perfmonctl':
: undefined reference to `__ia64_save_stack_nonlocal'
arch/ia64/kernel/built-in.o(.text+0x37c82): In function `dup_state_stack':
: undefined reference to `__ia64_save_stack_nonlocal'
arch/ia64/kernel/built-in.o(.text+0x382b2): In function `desc_prologue':
: undefined reference to `__ia64_save_stack_nonlocal'
arch/ia64/kernel/built-in.o(.text+0x3ad12): more undefined references to `__ia64_save_stack_nonlocal' follow

ia64 seems to break a lot.

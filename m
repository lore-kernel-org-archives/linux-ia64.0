From: Christian Kandeler <christian.kandeler@hob.de>
Date: Tue, 20 Feb 2007 10:07:05 +0000
Subject: Question about backing store access rights
Message-Id: <200702201107.05662.christian.kandeler@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I hope that someone can enlighten me about how the mapping of a process' RSE 
backing store page is supposed to work. 
From what I can see, the area gets initialized in the ia64_init_addr_space() 
function, where its vm_page_prot member is set to __P011, i.e. PAGE_READONLY, 
which I assume is supposed to be changed on the first write access. However, 
according to the IASDM, RSE stores always set ISR.w to zero on an 
interruption, so the page fault handler will never know that it's dealing 
with a write access. Consequently, processes should end up in an endless loop 
of IR Data Access Rights faults. Why don't they? What am I missing here?


Thanks,
Christian

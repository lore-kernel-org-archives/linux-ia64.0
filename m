From: Takanori Kawano <t-kawano@ebina.hitachi.co.jp>
Date: Wed, 09 Jan 2002 08:39:38 +0000
Subject: [Linux-ia64] Modifing memory attributes needs cache flush
Message-Id: <marc-linux-ia64-105590698805781@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It noticed current ia64 code doesn't flush any processor 
cache before modifing memory attributes, though the following 
description in SDM vol2 Section4.4.2 says it should be done.

 If software modifies the memory attributes for a page, software must flush
 any processor cache copies with the Flush Cache(fc) instruction for the 
 following memory attribute changes:
 speculative/non-speculative, cacheable/uncacheable(for transitions from 
 cacheable to uncacheable), and coherency. Software must flush any coalescing 
 buffers if a page is changes from coalescing to any other attribute.
 

Does anybody know why the current code doesn't flush cache?

I have some problem that seems to be caused by the ansence 
of cache flush and I am writing a patch fixes it, so I'll
appreciate any information about it.

---
Takanori Kawano
Hitachi Ltd,
Internet Systems Platform Division
t-kawano@ebina.hitachi.co.jp









From: <dhruv.anand@wipro.com>
Date: Mon, 01 Mar 2004 14:55:42 +0000
Subject: Issues regarding memory hole.
Message-Id: <CC7A2BA2F1CA9E43B2B62C4783B42C7BE2E7D7@blr-ec-msg05.wipro.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, 
I am booting with the 2.6.1 kernel on Itanium2 machine.
The page granularity is set to 16MB for the kernel. 

After normal boot of the kernel, I observe a memory hole 
from 1-16MB. Why is this usable memory region discarded 
as a memory hole? 

As per my understanding, the kernel requires contiguous 
Write-Back memory for allocation. Is this the only reason? 

Can this memory be reused after the kernel has booted?

Regards
Dhruv.

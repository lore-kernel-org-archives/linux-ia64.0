From: Christian Kandeler <christian.kandeler@hob.de>
Date: Thu, 24 May 2007 14:44:03 +0000
Subject: Question about output for PAL_VM_TR_READ call
Message-Id: <200705241644.03732.christian.kandeler@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I'd like to know why in the tr_info function in arch/ia64/kernel/palinfo.c the 
ppn and vpn values are left-shifted by 12 bits in the sprintf call. They are 
supposed to be page numbers, but this shift turns them into byte addresses, 
doesn't it?


Regards,
Christian Kandeler

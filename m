From: Matt Domsch <Matt_Domsch@Dell.com>
Date: Fri, 15 Aug 2003 17:48:38 +0000
Subject: no atomic_set/clear_mask
Message-Id: <marc-linux-ia64-106097001001798@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I see ia64 doesn't have atomic_set_mask() and atomic_clear_mask() 
functions.  I'm trying to deal with a page->flags corruption issue (not 
yet seen on IA-64, but there's no reason it couldn't be) where page->flags 
gets modified nonatomically while another CPU modifies individual bits 
atomically with set_bit() or clear_bit().

Would anyone like to take a stab at providing atomic_set_mask and 
atomic_clear_mask functions for IA64? :-)

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com


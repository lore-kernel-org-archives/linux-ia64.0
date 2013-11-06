From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 06 Nov 2013 19:26:25 +0000
Subject: re: [IA64] Failure to grow RBS
Message-Id: <20131106192625.GA22627@elgon.mountain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Andrew Burgess,

This is a semi-automatic email about new static checker warnings.

The patch e8c59c0cf9c9: "[IA64] Failure to grow RBS" from Aug 16, 
2007, leads to the following Smatch complaint:

arch/ia64/mm/fault.c:138 ia64_do_page_fault()
	 error: we previously assumed 'vma' could be null (see line 138)

arch/ia64/mm/fault.c
   137	         */
   138	        if (( !vma && prev_vma ) || (address < vma->vm_start) )
                      ^^^^                             ^^^^^^^^^^^^^
If !vma and !prev_vma then Oops.

   139			goto check_expansion;
   140	

regards,
dan carpenter

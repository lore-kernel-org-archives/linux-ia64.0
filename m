From: Matt_Domsch@Dell.com
Date: Mon, 03 Jun 2002 14:48:31 +0000
Subject: RE: [Linux-ia64] Integer to Pointer Cast Warnings when Building 2
Message-Id: <marc-linux-ia64-105590701905630@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905629@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905629@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> make[3]: Entering directory `/kernel/linux/drivers/scsi'
> megaraid.c: In function `megaraid_queue':
> megaraid.c:3805: warning: cast to pointer from integer of 
> different size

This one is OK, albeit not obvious.  That's inside an ioctl that can only be
called by a 32-bit user space application (no equivalent 64-bit app exists).
The code is:

  char *user_area = NULL;    
  user_area = (char *)*((u32*)&pScb->SCpnt->cmnd[4]);
  copy_to_user(user_area,...)

a 32-bit value which is a pointer inside a 32-bit application gets promoted
to a 64-bit pointer inside the ioctl so that copy_to_user can be used.

Thanks,
Matt 

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001!


From: Stephen Mulcahy <stephen.mulcahy@hp.com>
Date: Wed, 14 May 2003 16:25:18 +0000
Subject: [Linux-ia64] keyboard problems with post 2.4.17 kernels on proliant dl590 (itanium)
Message-Id: <marc-linux-ia64-105590723705796@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I've been having difficulty compiling a kernel that provides a working
keyboard from sources newer than 2.4.17 - is this a known problem
(google sheds no light on things)? I can't see anything in dmesg to
suggest an error but as soon as elilo hands loads the kernel, I lose
the ability to input anything through the keyboard.

This is with vanilla kernel sources (2.4.18, 2.4.19 and 2.4.20) +
official ia64 patches and with debian kernel sources.

thanks,

-stephen

-- 
   Stephen Mulcahy, Software Engineer, Mission Critical & Proactive Services,
     HP Customer Support R&D, HP, Ballybrit Business Park, Galway, Ireland.
             tel: +353-91-754584 / mailto:stephen.mulcahy@hp.com

The contents of this message and any attachments to it are confidential and may
be legally privileged. If you have received this message in error you should
delete it from your system immediately and advise the sender.

To any recipient of this message within HP, unless otherwise stated, you should
consider this message and attachments as "HP CONFIDENTIAL".



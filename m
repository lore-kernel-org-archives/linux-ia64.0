From: Sebastien Lelarge <Sebastien.Lelarge@bull.net>
Date: Thu, 04 Jul 2002 06:45:58 +0000
Subject: [Linux-ia64] [patch] kdb-v2.1-2.4.18-ia64-usb-keyboard
Message-Id: <marc-linux-ia64-105590701905735@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello list,

I'm student in France and I'm working on IA64 machines by BULL 
in France. We had a problem using KDB on Tiger machine because of the
lack of PS/2 port on this machine. In order to bring a solution, I
have written some code to bring USB support in KDB. I'm using a RedHat 
7.2. You must apply this patch after the 2 KDB patches. It provides an 
option called "Support for USB Keyboard in KDB" in Kernel Hacking
section. 

For now, it supports the usb-uhci driver for the USB controller. 
and supports the two USB keyboard drivers (hid and usbkbd) used by
RedHat.

Notice that you won't be able to use your USB Keyboard before USB
subsystem is started. But it's a solution to debug a system running.

You can download it at
ftp://oss.sgi.com/www/projects/kdb/download/v2.1/kdb-v2.1-2.4.18-ia64-usb-keyboard-2.bz2

For now, it works on kernel 2.4.18 with all recent patches. If you
have remarks, please reply adding kdb@oss.sgi.com in copy of your mail.

Thanks
-- 
LELARGE Sebastien			            
BULL S.A - Linux IA64 Team    mailto:sebastien.lelarge@bull.net
38000 Echirolles


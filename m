From: Grant Grundler <iod00d@hp.com>
Date: Thu, 16 Oct 2003 22:33:27 +0000
Subject: type 95 for .text?
Message-Id: <marc-linux-ia64-106634361902844@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


make install_modules for 2.4.23-pre6:
 ...
find kernel -path '*/pcmcia/*' -name '*.o' | xargs -i -r ln -sf ../{} pcmcia
if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.4.23-pre6; fi
depmod: Modules compiled with -mconstant-gp cannot be loaded of type 95 for .text                                                                               
depmod: Modules compiled with -mconstant-gp cannot be loaded of type 95 for .text
...
depmod: depmod obj_relocate failed                                              

using	modules-init-tools 0.9.15-pre2-2 
	gcc-3.3		3.3.2-0pre4
	binutils	2.14.90.0.6-3	 (also tried -4)


Anyone have a clue what this is about?

thanks,
grant

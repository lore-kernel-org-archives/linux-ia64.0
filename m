From: Wang Yi <wang_yi_2000@163.com>
Date: Sat, 11 May 2002 08:59:59 +0000
Subject: [Linux-ia64] Problem about NVidia driver 1.0-2880 on Linux-ia64 kernel 2.4.18
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------91675E51D624A09168691C45"
Message-Id: <marc-linux-ia64-105590701905571@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------91675E51D624A09168691C45
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: 7bit

There is no any mistake reported when build and install NVIDIA_kernel
dirver and NVIDIA_GLX driver.
glxinfo of XFree86 can provide corrent information after the new driver
is installed.
My OpenGL programs work well without recompilation.But when I rebuild
them, the ld report
                      /usr/lib/libGLcore.so.1: undefined reference to
'__nvsym10421'

The RedHat Linux for Itanium 7.1 installed on my machine has a version
2.4.3 kernel, which  cannot match the requirement of the NVdriver. So I
downloaded and installed the 2.4.18 kernel.
I unpack linux kernel 2.4.18 at ~/linux and build it successfully. It
works well also.

when I build the NVIDIA_kernel driver, I use the following command :
   make SYSINCLUDE=~/linux/include

I have tried several time to rebuild the driver. But the results are
same.

--------------91675E51D624A09168691C45
Content-Type: text/x-vcard; charset=gb2312;
 name="wang_yi_2000.vcf"
Content-Transfer-Encoding: 7bit
Content-Description: Card for Wang Yi
Content-Disposition: attachment;
 filename="wang_yi_2000.vcf"

begin:vcard 
n:;
x-mozilla-html:FALSE
adr:;;;;;;
version:2.1
x-mozilla-cpt:;-26096
end:vcard

--------------91675E51D624A09168691C45--



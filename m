From: "Ameya Mitragotri" <ameya.mitragotri@wipro.com>
Date: Thu, 09 Oct 2003 10:19:44 +0000
Subject: 2.6.0-Test5 booting problems on Itanium-1!
Message-Id: <marc-linux-ia64-106569415603393@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello, 
I am facing a strange problem trying to get 2.6.0-test5 booted on an 
Itanium-1 machine (its a beta processor). 

1) in my .config i have 
CONFIG_ITANIUM=y 
CONFIG_IA64_DIG=y 
CONFIG_IA64_PAGE_SIZE_16KB=y 

2) I compiled and made a vmlinux image. I copied the image to the
/boot/efi directory
and provided a softlink to the image in the /boot directory. 

now on a reboot, i get the 'booting linux-2.6.0-test5' message. Nothing
happens after this. Can anyone suggest any ways to resolve this? 

I also tried to boot using a gzipped image (vmlinux.gz) but i get an
error "min_addr not page aligned" 

Any suggestions will be really helpful. 

Thanks
ameya

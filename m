From: Alex Williamson <alex_williamson@hp.com>
Date: Wed, 30 Oct 2002 17:01:53 +0000
Subject: Re: [Linux-ia64] PXE boot off HP zx6000
Message-Id: <marc-linux-ia64-105590709805299@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805294@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805294@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jason,

   Here's a know configuration that works:

   Debian 3.0 server (ia32)
     tftpd-hpa      0.28-2
     dhcp           2.0pl5-11

/etc/inetd.conf:
tftp dgram udp wait root /usr/sbin/in.tftpd in.tftpd -t 1
 -s /tftpboot

/etc/dhcpd.conf
        host zx6000 { 
                hardware ethernet xx:xx:xx:xx:xx:xx;
                fixed-address zx6000;
                filename "elilo.efi";
        }

You'll need an elilo.conf or some permutation of AABBCCDD.conf,
which is your IP in hex (just like pxelinux).  Is the kernel
file elilo.conf points at stripped?  You may want to strip it
and gzip it to see if that helps.  Look in the logs to see
what it's transfered and which file it's getting an error on.
Are you loading an initrd as well (what size)?  What firmware
is on your zx6000 ('info fw' from efi)?  Thanks,

	Alex
--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO


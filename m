From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 16 Jan 2002 21:02:06 +0000
Subject: Re: [Linux-ia64] PXE booting, one last question
Message-Id: <marc-linux-ia64-105590698805861@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805860@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805860@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mike,

On Wed, Jan 16, 2002 at 12:37:54PM -0800, Michael Madore wrote:
> Does anyone have a sample elilo.conf file for booting the kernel and
> then mounting an initial ramdisk?  I have an elilo.conf that works for
> loading and mounting a ramdisk from an LS-120, but it can't mount the
> ramdisk when booting via the network.  I checked my tftpd log, and the
> initial ramdisk is getting transferred to the client.
> 

Something like that should work:

image=/vmlinuz.initrd
        label=linux-initrd
        initrd=/initrd-2.4.3

All paths must be related to the tftpd root directory, nothing gets added
by elilo.

-- 
-Stephane


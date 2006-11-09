From: "Karthik Gopalakrishnan" <karthik.g.krishnan@gmail.com>
Date: Thu, 09 Nov 2006 12:46:04 +0000
Subject: elilo.efi causing Kernel Panic
Message-Id: <5e0a1fd80611090434o7e2d4cadmb9b29f50f7b95759@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061109124221.GL16952@parisc-linux.org>
In-Reply-To: <20061109124221.GL16952@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Folks.

    I compiled elilo-3.4 from source using gnu-efi-3.0c toolchain.
Compilation went fine. However, booting from the new elilo.efi binary
results in the following Kernel Panic:

VFS: Unable to mount root fs on unknown-block(0,0)

    The elilo.efi shipped with RHEL works without problems.

    I am using an ia64 hp superdome server SD32A running Red Hat
Enterprise Linux AS release 4 (Nahant Update 2)

Here is some Console Information.

fs0:\EFI\redhat> type elilo.conf
File: fs0:\EFI\redhat\elilo.conf, Size 174

prompt
timeout 
default=linux
relocatable

image=vmlinuz-2.6.9-22.EL
        label=linux
        initrd=initrd-2.6.9-22.EL.img
        read-only
        append="console=ttyS0 rhgb quiet root=LABEL=/"

fs0:\EFI\redhat> elilo

ELILO boot: Uncompressing Linux... done
Loading initrd initrd-2.6.9-22.EL.img...done
i8042.c: No controller found.
ernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)

    Any help will be greatly appreciated.

Regards,
Karthik

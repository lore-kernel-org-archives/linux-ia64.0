From: Jared Egolf <jegolf@yahoo.com>
Date: Fri, 16 Nov 2001 00:33:54 +0000
Subject: [Linux-ia64] kernel panic on root mount / EFI =?unknown-8bit?q?can=E2=80=99t?= see /boot/efi partition!
Message-Id: <marc-linux-ia64-105590698805521@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Using Redhat 7.2 and in the past 7.1, I cannot configure
the /boot/efi partition with such a type definition that
EFI will recognize the file-system and thus use it for
booting purposes.  Our boot procedure has been to boot into
Whistler and copy over the data to a LS120 and then setup
to boot from there.  This is occurring on our BigSur, Lion,
and Azusa machines.
Unfortunately, whenever I rebuild a kernel, (currently
attempting with 2.4.14, but also tried 2.4.10 and have only
tested on the BigSur), the kernel panics without being
capable of mounting the root partition.  This occurs even
with the default configuration of the kernel and I suspect
the two problems may be linked.  It is troubling however
that while the default Redhat kernel will mount the (/)
root system after loading the qla1260 driver from the
initrd file, when I have my new kernel configured to
compile and include qla1260 it still results in a kernel
panic.  Is building an initrd file for each kernel rebuild
truly going to help the situation?  Has anybody else seen a
situation where EFI refuses to recognize a FAT16 defined
partition?  Perhaps Whistler is mangling the partition
tables on all the accessible disks?  Could these problems
be linked?
Thank-you for your help,
Jared Egolf


__________________________________________________
Do You Yahoo!?
Find the one for you at Yahoo! Personals
http://personals.yahoo.com


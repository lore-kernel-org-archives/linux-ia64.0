From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 23 Nov 2004 15:13:27 +0000
Subject: SELinux & ia64
Message-Id: <41A35397.1080001@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, selinux@tycho.nsa.gov

SELinux appears to cause warnings while attempting mounts both at 
boot-time and run-time:

kernel unaligned access to 0xa0000002003a0056, ip=0xa0000001002076d0
kernel unaligned access to 0xa0000002003a005e, ip=0xa0000001002076d0
kernel unaligned access to 0xa0000002003a0066, ip=0xa0000001002076d0
kernel unaligned access to 0xa0000002003a006e, ip=0xa0000001002076d0

I've tracked this to the usage of le32_to_cpu in 

security/selinux/ss/policydb.c

The code in question uses:

    len = le32_to_cpu(buf[0]);

and should be

    len = le32_to_cpu(get_unaligned(&buf[0]));

However, this is probably not a good solution as the get_unaligned macro 
can be expensive
on platforms other than ia64. 

I'm tempted to redefine the le32_to_cpu function for policydb.c for the 
ia64 platform, but
before I go down that road I was wondering if anyone had hit this issue 
elsewhere in the kernel?

Prarit.

From: Ronald Veldema <veldema@cs.fau.de>
Date: Tue, 27 May 2003 19:55:05 +0000
Subject: [Linux-ia64] mmap failure
Message-Id: <marc-linux-ia64-105590723706049@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,
    it looks like mmap fails when calling mmap as:

    mmap(0x30000066910000,
                16384,
            PROT_READ | PROT_WRITE,  
          MAP_FIXED,MAP_PRIVATE,
       fd,0x30000066910000);

Other addresses are ok. It fails with EINVAL.
Is 0x30000... reserved for the kernel ?
R.
      



From: "Pereira, D LailaX E" <d.lailax.e.pereira@intel.com>
Date: Mon, 29 Oct 2001 16:58:02 +0000
Subject: [Linux-ia64] SIGSEGV access type during pagefault
Message-Id: <marc-linux-ia64-105590698805406@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi 
I am trying to write a SEGV handler  for a system running on linux with
itanium  processor.
I want to find out , what type access (READ or WRITE) causes the page fault?
I want to if there is any indication during SIGSEGV , that I can use to find
out whether a READ caused the pagefault or a WRITE caused the pagefault?
Please let me know about this.
thanks



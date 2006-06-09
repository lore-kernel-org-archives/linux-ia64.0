From: "vamsi krishna" <vamsi.krishnak@gmail.com>
Date: Fri, 09 Jun 2006 06:59:54 +0000
Subject: [FIXED] Question about the segment [[ 60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00
Message-Id: <3faf05680606082359m32cea491m396df061c3797ff2@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello All,

Thank you for all your comments, I fixed my issue on linuxipf. The
problem is a standard memory corruption problem. I had a 'FILE *ptr'
which was opened in the save run, during the restore run since the
FILE *'s are not restored I reopen the FILE * and do a memcpy into
*ptr since in the restore run *ptr is not a valid memory this caused
the corruption and _IO_flush_all was stuck.

Thank you once again.

Best,
Vamsi

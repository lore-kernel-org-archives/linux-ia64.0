From: Bill Nottingham <notting@redhat.com>
Date: Mon, 12 Nov 2001 17:01:57 +0000
Subject: [Linux-ia64] Re: Unaligned access in ia64
Message-Id: <marc-linux-ia64-105590698805475@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Pereira, D LailaX E (d.lailax.e.pereira@intel.com) said: 
> warning: cast from pointer to integer of different size
> This happens when I convert (void*) pointer to int i. 

Well, yes, because they aren't the same size.

Bill


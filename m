From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 May 2003 17:24:18 +0000
Subject: [Linux-ia64] Re: kernel 2.5.69 doesn't compile for UP
Message-Id: <marc-linux-ia64-105590723705800@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 May 2003 15:31:08 +0200, Eric Piel <Eric.Piel@Bull.Net> said:

  Eric> It's a bit obvious, in UP tasklist_lock doesn't contain any
  Eric> member :-( The attached patch let the compilation go. However
  Eric> I don't think it looks good, there is probably a cleaner way
  Eric> to solve this problem but my knowledge about the locks is
  Eric> really too little...

Ah, yes indeed.  I'll fix that.

Thanks,

	--david


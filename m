From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 Mar 2003 17:46:45 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806062@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 12 Mar 2003 10:07:36 -0700, n0ano@n0ano.com said:

  Don> Because 32K is not supported by the hardware and last time I
  Don> tried Linux had probllems with page sizes >= 64K.  The scsi
  Don> code used a bit map that blew up with large page sizes.  I know
  Don> someone created a patch to fix this problem but I don't know if
  Don> it made it into the official tree.

Yes, I fixed the SCSI problems for 2.4.  However, there were also some
second-order issues in the file/block-subsystems.

I probably don't remember all the details, but one example is that the
disk block-size used to be stored in a 16 bit variable.  Not so good
if your block-size is 64KB. ;-) That one definitely has been fixed.
But I wouldn't blindly trust that the 64KB page size is fully working,
even if there are currently no known problems.

	--david


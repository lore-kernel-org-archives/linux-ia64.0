From: j-nomura@ce.jp.nec.com
Date: Tue, 11 Jun 2002 07:55:15 +0000
Subject: Re: [Linux-ia64] CD-ROM I/O error
Message-Id: <marc-linux-ia64-105590701905663@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905659@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905659@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> > when I do 'cat /dev/cdrom > disc.iso' on my Itanium box,
> > I/O error happens on CD-ROM.
> 
> If you're trying to simply make an ISO with the right number of sectors, you
> need to use 'isoinfo' to avoid these kinds of end-of-disc problems.

Thank you, Matt.
I had to specify the number of blocks to read.

I'm still wondering why this does neither occur on my Pentium box
nor for some other CDs..

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com, nomura@hpc.bs1.fc.nec.co.jp>
HPC Operating System Group, 1st Computers Software Division,
Computers Software Operations Unit, NEC Solutions.


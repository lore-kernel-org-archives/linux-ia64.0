From: Kazuto Miyoshi <miyoshi@linux.bs1.fc.nec.co.jp>
Date: Thu, 16 Sep 2004 13:51:09 +0000
Subject: Re: INIT dumps broken?
Message-Id: <20040916.225109.395614316.miyoshi@linux.bs1.fc.nec.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hello, 

Thank you for detailed explanation.

> So if our task is anything other than the initial "init_task",
> we'll take a nice region 7 address from ar.k6, and convert to
> physical by zapping bits [63:61].  But we happen to be running
> the init_task, then ar.k6 contains a region 5 address, and we
> create a garbage address by clearing the high bits, which can
> lead to an MCA (if the address points somewhere bad) or to
> stomping on some random place (if the address happens to be a
> legal physical address).

I checked the INIT log and it showed r13 and xip had actually 0xa..
address, the "stomping on some random place" scenario is probable.
I tried reducing memory from 2GB and it reproduced the MCA.

Best Regards,
--
Kazuto Miyoshi, NEC
miyoshi@hpc.bs1.fc.nec.co.jp

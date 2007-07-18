From: "Martin K. Petersen" <martin.petersen@oracle.com>
Date: Wed, 18 Jul 2007 21:18:50 +0000
Subject: Re: debian 40r installation issue on IA 64
Message-Id: <yq1ps2p2yx1.fsf@sermon.lab.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <426724.15340.qm@web58005.mail.re3.yahoo.com>
In-Reply-To: <426724.15340.qm@web58005.mail.re3.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Bjorn" = Bjorn Helgaas <bjorn.helgaas@hp.com> writes:

>> I have been trying to install debian 40r0 on hp longs peak itanium
>> server. The installation hangs trying to configure net....

I ran into this yesterday.  Upgrading the MP firmware to 3.30 fixed
the problem...

-- 
Martin K. Petersen	Oracle Linux Engineering


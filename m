From: Grant Grundler <iod00d@hp.com>
Date: Thu, 18 Dec 2003 20:29:05 +0000
Subject: Re: IA64 test report: 2.6.0-test11/tiger 2003-12-18: 9/9 pass
Message-Id: <marc-linux-ia64-107177939424641@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107174005310297@msgid-missing>
In-Reply-To: <marc-linux-ia64-107174005310297@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Dec 18, 2003 at 12:56:14PM -0700, Bjorn Helgaas wrote:
> (What does it mean to have an
> address space descriptor that starts at 0xffffffff and ends at 0x0?)

For PCI-PCI bridges, it means disable that particular window/range register.
ie don't decode and route transactions. Not sure that's what is
intended since since I don't know who is intended to "consume" the
offending entries.

grant

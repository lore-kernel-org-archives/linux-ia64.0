From: Grant Grundler <iod00d@hp.com>
Date: Thu, 25 Dec 2003 07:37:01 +0000
Subject: Re: IA64 test report: 2.6.0-test11/tiger 2003-12-18: 9/9 pass
Message-Id: <marc-linux-ia64-107233783423867@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107174005310297@msgid-missing>
In-Reply-To: <marc-linux-ia64-107174005310297@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Dec 25, 2003 at 03:14:25PM +0800, Yu, Luming wrote:
> >> (What does it mean to have an
> >> address space descriptor that starts at 0xffffffff and ends at 0x0?)
> >For PCI-PCI bridges, it means disable that particular window/range
> register.
> >ie don't decode and route transactions. 
> 
> But I didn't find this kind of explanation on ACPI spec.

I was just commenting on how PCI-PCI Bridges behave and I know OS code
(both linux and hpux) expects this behavior.

I have no idea what ACPI says about this or even if ACPI
specification should dictate this behavior.

grant

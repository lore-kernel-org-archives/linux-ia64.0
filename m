From: Grant Grundler <grundler@cup.hp.com>
Date: Mon, 01 Jul 2002 21:07:07 +0000
Subject: Re: [Linux-ia64] Diff b/w 32Bit & 64Bit
Message-Id: <marc-linux-ia64-105590701905729@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905728@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905728@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Mohamed Ghouse , Gurgaon" wrote:
> Hello Sir

Hi,
This is a mailing list - I would assume some women are also subscribed.

> I am developing a Driver
> I want to know the differences between of Linux on a 32-Bit Processor & a
> 64-Bit processor(Processor assumed to be Intel's x86) .

uhm...Intel doesn't ship a 64-bit x86 processor. Only AMD is very
publicly trying to do that. If you want to know how linux runs on IA64,
then buy David Mosberger and Stephane Eranian's excellent book
appropriately titled "IA-64 Linux".

You should look at any of the numerous "How-TO write a driver":
http://www.linuxhq.com/kernel/v2.4/doc/pci.txt.html
http://www.cs.arizona.edu/computer.help/policy/DIGITAL\_unix/AA-Q7RQC-TE\_html/pcibus3.html

or talks recently presented at OLS by Arjan van de Ven,
Greg Kroah-Hartman, or myself:
	http://www.linuxsymposium.org/2002/

grant


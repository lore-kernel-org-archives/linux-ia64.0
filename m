From: Grant Grundler <iod00d@hp.com>
Date: Thu, 07 Aug 2003 19:42:10 +0000
Subject: Re: IPMI Help to access Firmware Versions.
Message-Id: <marc-linux-ia64-106028542207291@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106026637713348@msgid-missing>
In-Reply-To: <marc-linux-ia64-106026637713348@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 07, 2003 at 07:51:14PM +0530, Kamesh Reddy wrote:
> I want to access the various firmware versions of devices like MP, BMC of the
> machine running Linux (64 Bit) etc.

EFI shell doesn't provide this?
Or you want to read this info programmatically while the OS is running?
perhaps under /proc/ someplace?
I looked around a bit but didn't see aything obvious.


> I have understood that this can be done
> using IPMI. I want to know if IPMI is implemented on Linux 64.

yes
 
> If so how do
> I use it (IPMI) to get the information I need.

I'd like to know as well.

thanks
grant


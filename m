From: Grant Grundler <iod00d@hp.com>
Date: Fri, 04 Jul 2003 12:56:55 +0000
Subject: Re: Reliably creating MCA on white box Itanium-1
Message-Id: <marc-linux-ia64-105732359723113@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105721395828393@msgid-missing>
In-Reply-To: <marc-linux-ia64-105721395828393@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 04, 2003 at 11:26:37AM +1000, Keith Owens wrote:
> Because mca_asm.S does not call the C code for TLB errors.  I want to
> test the C code on standard hardware.

will "cat /dev/mem > /dev/null" work for you?

I know xdm used to MCA the box becuase it was reading /dev/mem.

grant

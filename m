From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 02 Apr 2004 01:40:18 +0000
Subject: Re: [PATCH] early serial console support
Message-Id: <16492.50306.257750.615958@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404011521.16402.bjorn.helgaas@hp.com>
In-Reply-To: <200404011521.16402.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 1 Apr 2004 15:21:16 -0700, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> +	while (!(UART_LSR_TEMT & serial_in(up, UART_LSR)))
  Bjorn> +		;

This needs a cpu_relax()?

	--david

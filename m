From: Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>
Date: Fri, 12 Sep 2003 12:43:19 +0000
Subject: Re: kernel update (relative to 2.4.22)
Message-Id: <marc-linux-ia64-106337080017397@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106312897006127@msgid-missing>
In-Reply-To: <marc-linux-ia64-106312897006127@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Bjorn,

For NUMA configuration, we need the attached patch which is
the same fix as 2.6.  I confirmed both the DIG and GENERIC
kernels boot on 8-way (2-node) NEC TX7.

As for drivers/acpi/tables.c part, I think Andrew or Len is
already aware.

From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: kernel update (relative to 2.4.22)
Date: Tue, 9 Sep 2003 11:28:32 -0600

>   * SGI SN and NUMA support:
>     - add NUMA support (Jesse Barnes, Takayoshi Kochi, Jack Steiner, others).
>     - support for non-identity-mapped kernels (Jack Steiner).
>     - misc SGI fixes (Jack Steiner).
>     - another SGI update (Erik Jacobson).

Takayoshi Kochi

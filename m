From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 29 Apr 2002 18:41:42 +0000
Subject: Re: [Linux-ia64] ACPI without PCI
Message-Id: <marc-linux-ia64-105590701905537@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905533@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905533@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 27 Apr 2002 16:35:48 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> Either ia64 config.in must force PCI=y or acpi_osl must cope
  Keith> with PCI=n.

It seems to me the latter would be the cleaner solution.

	--david


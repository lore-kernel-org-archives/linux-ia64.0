From: Jacqueline Lemaitre <Jacqueline.Lemaitre@bull.net>
Date: Fri, 22 Feb 2002 14:45:47 +0000
Subject: Re: [Linux-ia64] Poweroff
Message-Id: <marc-linux-ia64-105590701905167@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905158@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905158@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

KOCHI, Takayoshi wrote :

> If a machine implements ACPI functionality (both hardware and
> firmware),  powering off should work fine.  At least
> poweroff command works on NEC's AzusA.

I am sorry, it was just a configuration problem.
I thought that CONFIG_ACPI was sufficient.
After I set the CONFIG_ACPI_SYS, I test it on AzusA and it works fine.

Thanks

Jacqueline


From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Jun 2003 18:47:57 +0000
Subject: Re: [Linux-ia64] RE: [ACPI] acpi_irq_to_vector()
Message-Id: <marc-linux-ia64-105639411317142@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105634836206576@msgid-missing>
In-Reply-To: <marc-linux-ia64-105634836206576@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Jun 2003 14:15:07 +0800, "Yu, Luming" <luming.yu@intel.com> said:

  Linux> To remove the ugly ifdef in the common part of ACPI code, I
  Linux> think the simple way is to define a acpi_irq_to_vector in
  Linux> arch/i386/acpi which only return acpi_fadt.sci_int.  Or
  Linux> someone can invent a method that can return correct value for
  Linux> each platform.

Shouldn't this be called acpi_gsi_to_irq(), though?

	--david

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

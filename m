From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 03 Jun 2002 17:23:09 +0000
Subject: Re: [Linux-ia64] Integer to Pointer Cast Warnings when Building 2.4.17
Message-Id: <marc-linux-ia64-105590701905632@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905629@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905629@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 3 Jun 2002 17:57:47 +0530, "LAKSHMIPATHY,ARUN (HP-India,ex2)" <arun_lakshmipathy@hp.com> said:

  Arun> make[4]: Entering directory
  Arun> `/kernel/linux/drivers/acpi/dispatcher' dswexec.c: In function
  Arun> `acpi_ds_exec_end_op': dswexec.c:580: warning: cast from
  Arun> pointer to integer of different size

  Arun> make[4]: Entering directory
  Arun> `/kernel/linux/drivers/acpi/events' evevent.c: In function
  Arun> `acpi_ev_asynch_execute_gpe_method': evevent.c:686: warning:
  Arun> cast from pointer to integer of different size evevent.c: In
  Arun> function `acpi_ev_gpe_dispatch': evevent.c:802: warning: cast
  Arun> to pointer from integer of different size

  Arun> make[3]: Entering directory `/kernel/linux/drivers/acpi' os.c:
  Arun> In function `acpi_os_get_root_pointer': os.c:206: warning:
  Arun> assignment makes integer from pointer without a cast

These come from the ACPI subsystem.  They annoy me, too, but it's up
to the ACPI folks to fix them.  It's possible they're already fixed in
the latest ACPI drops.

	--david


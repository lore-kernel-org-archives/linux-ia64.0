From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 21 Jan 2003 22:04:25 +0000
Subject: Re: [Linux-ia64] EFI serial discovery support
Message-Id: <marc-linux-ia64-105590709805739@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805732@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805732@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 21 Jan 2003 13:17:57 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Hi, With 2.5.52 and the IA64 patch, on an HP ZX1, if I
  Peter> specify serial discovery via the EFI HDCP tables, no serial
  Peter> ports are found.

  Peter> The ACPI tables work.

What firmware rev are you at?  You might also want to try to go into
the EFI console setup menu and select the serial port as the output
device (yes, I realize that you probably have done that already, but
it seems that sometimes (after a fw-upgrade?) you need to redo this to
ensure that the HCDP table is in sync with the EFI console selection).

	--david


From: Michael Madore <mmadore@turbolinux.com>
Date: Wed, 16 Jan 2002 18:57:25 +0000
Subject: [Linux-ia64] PXE Boot
Message-Id: <marc-linux-ia64-105590698805845@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I'm trying to boot a Big Sur workstation (Firmware 117C) via the
network.  The workstation receives an address via dhcp and when starting
to download elilo.efi I get the following error message:

PXE-E05: Download buffer is smaller than requested file.
Load of PXE boot failed:  File not found

Does this message really indicate the buffer is to small, or is this a
symptom of a different problem?

Mike


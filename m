From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 16 Jan 2002 18:23:41 +0000
Subject: Re: [Linux-ia64] PXE Boot
Message-Id: <marc-linux-ia64-105590698805848@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mike,

On Wed, Jan 16, 2002 at 10:57:25AM -0800, Michael Madore wrote:
> 
> I'm trying to boot a Big Sur workstation (Firmware 117C) via the
> network.  The workstation receives an address via dhcp and when starting
> to download elilo.efi I get the following error message:
> 
> PXE-E05: Download buffer is smaller than requested file.
> Load of PXE boot failed:  File not found
> 
Do you get this everytime? I have already seen this problem but it disappears
if you retry, if I recall correctly.

> Does this message really indicate the buffer is to small, or is this a
> symptom of a different problem?
> 
Are you using a PXE-aware DHCP server or a standard DHCP server?


-- 

-Stephane


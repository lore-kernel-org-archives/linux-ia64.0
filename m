From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Thu, 14 Aug 2003 01:28:15 +0000
Subject: RE: EFI boot manager fail-over behavior question
Message-Id: <marc-linux-ia64-106082454908302@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106081992104989@msgid-missing>
In-Reply-To: <marc-linux-ia64-106081992104989@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane,

> EFI Boot Manager ver 1.10 [14.61]  Firmware ver 2.00 [4318]

Looks like the sample implementation, yes?

> Could somebody more familiar than me  with the boot manager 
> clarify this?

I have heard of similar problems specifically relating to netbooting with the sample implementation.  Is the behavior correct (traverses the boot option list) if you select a different, non-netbooting option?  

matt 

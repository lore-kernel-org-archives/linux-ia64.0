From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 08 Aug 2001 14:30:49 +0000
Subject: Re: [Linux-ia64] AGP
Message-Id: <marc-linux-ia64-105590693006012@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693006009@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693006009@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I am wondering to which extent AGP and DRI are supported by Linux-IA64.

My experience on an HP i2000 (which I guess is basically a BigSur) running 
RedHat 7.1 (2.4.3 kernel, 4.0.3 XFree86):

	Nvidia Quadro2 Pro (default card): X works but no DRI
	Matrox G400: DRI works

I have also tried the G400 with a 2.4.5 kernel.  X works fine, but DRI is 
broken somehow.  This is with 2.4.5 + AGP/DRM-related patches from the 
RedHat 2.4.3 kernel.  I've exchanged email with Chris Ahna, who did the 
GART code for the 460GX chipset in these boxes, and he's planning to look 
into the problems when he returns from vacation next week.

Bjorn


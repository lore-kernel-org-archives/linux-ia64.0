From: "Wichmann, Mats D" <mats.d.wichmann@intel.com>
Date: Tue, 11 Mar 2003 23:18:15 +0000
Subject: RE: [Linux-ia64] 2.4.20 / DIG
Message-Id: <marc-linux-ia64-105590709806041@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806024@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806024@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> I am trying to compile Bjorn's 2.4.20 kernel on my old Intel C0 based
> box with a RH7.2 install on it (with updates), gcc-2.96.
> 
> The Red Hat 2.4.9 kernels work just fine on it, but my selfcompiled
> 2.4.20 kernels explode before it gets to probing the SCSI bus. In SMP
> mode it reboots so fast I can't see exactly where it hands, if I set
> maxcpus=1 it gets to saying EFI Variables Facility - then hangs for a
> bit and then reboots.
> 
> Is this a known problem? Any clues?

I'd bet your firmware's out of date.  I got around 
the same problem by upgrading.



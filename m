From: "Broadfoot, KenX" <kenx.broadfoot@intel.com>
Date: Tue, 08 Aug 2000 16:02:51 +0000
Subject: RE: [Linux-ia64] Kernel: which machine to choose?
Message-Id: <marc-linux-ia64-105590678205275@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I use:

DIG-compliant
Enable Itanium A-step
Enable Itanium A1-step
Enable AzusA hacks
Enable IA64 Machine Check Abort
SMP support

----------------------------------------------------------------

I am not using SoftSDV hacks ( strange I know )
I compile SMP even for the single proc box. It just "seems" more stable.

My uptime is 4 days and 20 hours as of this writing.

--ken

> -----Original Message-----
> From:	G\351raud Krawezik [SMTP:gk@scali.no]
> Sent:	Tuesday, August 08, 2000 12:15 AM
> To:	linux-ia64@linuxia64.com
> Subject:	[Linux-ia64] Kernel: which machine to choose?
> 
> Hello,
> 
> In order to use a kernel that support modules, I have downloaded
> 2.4.0-test5.
> There are four different kind of workstations available: Generic,
> HP-simulator, SN1, DIG Compliant.
> 
> HP-Sim crashes at the very beginning of the booting sequence
> SN1 cannot compile
> DIG compliant crashes while booting.
> 
> I'm ok to make minor modifications by myself to haev this fixed, but could
> someone tell me what version should I use? (from what I have seen, Generic
> uses all the others, so it does not compile and some definitions seem to
> be rather old...)
> I'm using an SDV from intel.
> 
> 
> Thanks by advance
> 
> 
> Geraud
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64



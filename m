From: "McCaffity, Ray" <ray.mccaffity@wcg.com>
Date: Tue, 01 May 2001 16:41:43 +0000
Subject: RE: [Linux-ia64] [PATCH] 2.4.3-ac14 remove three IA-64 related or
Message-Id: <marc-linux-ia64-105590693005497@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005460@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005460@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is there an easy way to tell what stepping your CPU supports?

Ray

-----Original Message-----
From: Chris McDermott [mailto:mcdermoc@us.ibm.com]
Sent: Tuesday, May 01, 2001 10:49 AM
To: scole@lanl.gov
Cc: alan@lxorguk.ukuu.org.uk; elenstev@mesatop.com; esr@thyrsus.com;
kaos@ocs.com.au; linux-ia64@linuxia64.org;
linux-ia64-admin@linuxia64.org
Subject: Re: [Linux-ia64] [PATCH] 2.4.3-ac14 remove three IA-64 related
orphans from Configure.help



Actually, CONFIG_ITANIUM_PTCG is still required if you have systems with
Itanium
processor steppings less than B3. I still have some of these and I'm sure
there are
quite a few others out there who still do as well.

Chris McDermott
IBM Linux Technology Center (LTC)
IA-64 Enablement




 

                    Steven Cole

                    <scole@lanl.gov>           To:
alan@lxorguk.ukuu.org.uk                                         
                    Sent by:                   cc:
linux-ia64@linuxia64.org, kaos@ocs.com.au, esr@thyrsus.com,      
                    linux-ia64-admin@lin        elenstev@mesatop.com

                    uxia64.org                 Subject:     [Linux-ia64]
[PATCH] 2.4.3-ac14 remove three IA-64 related  
                                                orphans from Configure.help

 

                    04/25/01 07:54 AM

                    Please respond to

                    scole

 

 





Alan,

The following three Configure.help entries have been confirmed dead, or
not needing help by Keith Owens.

The last of these, CONFIG_IA64_AZUSA_HACKS,  is listed by Keith as
removed by a 2.4.2-ia64-010228 patch, but it still appears in 2.4.3-ac14.

Steven

--- linux/Documentation/Configure.help.ac14     Wed Apr 25 08:14:33 2001
+++ linux/Documentation/Configure.help  Wed Apr 25 08:40:50 2001
@@ -18611,22 +18611,6 @@
   redirect interrupts to different CPUs.  Select N here if you're
   unsure.

-Enable use of global TLB purge instruction (ptc.g)
-CONFIG_ITANIUM_PTCG
-  Say Y here if you want the kernel to use the IA-64 "ptc.g"
-  instruction to flush the TLB on all CPUs.  Select N here if
-  you're unsure.
-
-Enable SoftSDV hacks
-CONFIG_IA64_SOFTSDV_HACKS
-  Say Y here to enable hacks to make the kernel work on the Intel
-  SoftSDV simulator.  Select N here if you're unsure.
-
-Enable AzusA hacks
-CONFIG_IA64_AZUSA_HACKS
-  Say Y here to enable hacks to make the kernel work on the NEC
-  AzusA platform.  Select N here if you're unsure.
-
 Enable IA-64 Machine Check Abort
 CONFIG_IA64_MCA
   Say Y here to enable machine check support for IA-64.  If you're

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64




_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


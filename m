From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 29 Oct 2002 16:29:13 +0000
Subject: RE: [Linux-ia64] RAW dependency in ivt.S
Message-Id: <marc-linux-ia64-105590709805284@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805283@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805283@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Check section 5.3 in document "The Intel Itanium Architecture Software Developer's Manual" volume 3.  There is no semantics of dependency required for this type of instance.  If you would add the stop bit, the code will expand into 2 bundles instead of possibly one in the original form.

- Ken


-----Original Message-----
From: Christian Hildner [mailto:christian.hildner@hob.de]
Sent: Tuesday, October 29, 2002 5:43 AM
To: linux ia64 kernel list
Subject: [Linux-ia64] RAW dependency in ivt.S


Hi,

testing the kernel 2.4.18 I found a RAW dependency (for P8) in ivt.S in
entry alt_dtlb_miss. The lines are

    cmp.ne p8,p0=r0,r23
(p8)    br.cond.spnt page_fault

Why I'am not providing a (simple) patch: I' am wondering about taking
the privilege level for the decision about taking a page fault or
inserting the identity mapped TLB entry. For my understanding there
should be checked for region 7.

Christian


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


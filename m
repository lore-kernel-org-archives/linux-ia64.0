From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Thu, 13 Nov 2003 16:21:02 +0000
Subject: Machine check when executing ptc.ga
Message-Id: <marc-linux-ia64-106874043202631@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've got a machine check when executing ptc.ga inside
ia64_global_tlb_purge() on an Intel Tiger box. The CPUs are:

family     : Itanium 2
model      : 1
revision   : 5

The failing instruction is:

       ptc.ga r32,r34;;

and r32 = a0000000 00000000, r34 = 00000000 00000040.

The Intel SDM Vol 3, page 3:200 says about the ptc.* instructions:
"Interruptions: Machine Check abort: Register NaT Consumption fault"

I checked with an ITP just before executing ptc.ga, the NaT bits
for r32 and r34 are 0.

What is the reason of this machine check?
Is there something non documented problem with ptc.ga ?

(I'm on a 2.4.20, but a ptc.ga should be the same...)
Thank you in advance.

Zoltan Menyhart

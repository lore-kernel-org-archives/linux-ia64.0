From: "Jim Hull" <jim.hull@hp.com>
Date: Fri, 30 Apr 2004 17:36:32 +0000
Subject: RE: cr.gpta register
Message-Id: <01b101c42ed9$ada1f5b0$f463f40f@jh733133>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040426123437.GA6567@cse.unsw.EDU.AU>
In-Reply-To: <20040426123437.GA6567@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

GPTA (CR9) exists solely to support the IA-32 System Environment (see
PAL_ENTER_IA_32_ENV in SDM Volume 2, Chapter 11).  All details concerning the
format and operation of this register are considered Intel Restricted.

From the perspective of an ia64 OS, GPTA should be treated as a Reserved
register - it will be initialized by PAL at reset, and the OS should never touch
it.

 -- Jim
    HP Itanium Processor Architect

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org 
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Matt Chapman
> Sent: Monday, April 26, 2004 5:35 AM
> To: linux-ia64@vger.kernel.org
> Subject: cr.gpta register
> 
> 
> Can anyone tell me what is the purpose of the cr.gpta (Guest 
> Page Table
> Address) register?  It is referred to in the ASDM and 
> elsewhere but not
> explicitly documented.
> 
> Thanks,
> Matt
> 
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


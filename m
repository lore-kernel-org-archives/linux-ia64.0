From: Zoltan Menyhart <Zoltan.Menyhart@free.fr>
Date: Tue, 21 Mar 2006 23:31:33 +0000
Subject: MCA: Should we always wake up the non-monarch CPUs?
Message-Id: <44208CD5.2010206@free.fr>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The MCA handler always releases the non-monarch CPUs from the
rendez-vous before returning to the SAL.

It is quite o.k. if the MCA has been recovered.

Yet, if the MCA cannot be recovered, what is the use of releasing
the non-monarch CPUs from the rendez-vous?
(It is much more easy to analyze the system state by use of some
"external intelligence" if the non-monarch CPUs cannot run after
an MCA for some considerably long time.)

As far as I can see in the flow chart of the MCA handling in the
SAL spec. (Dec. 2003, figure 4-6, page 61), it indicates that a
_typical_ MCA handler should wake up the non-monarch CPUs.

Do I interpret correctly the spec. saying it is not an obligation,
and the monarch CPU can return to the SAL and can request a reboot
without waking up the non-monarch CPUs?

Thanks,

Zoltan Menyhart


From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 13 Apr 2004 17:24:45 +0000
Subject: RE: Questions on the stack for IA64
Message-Id: <200404131724.i3DHOiF18600@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
In-Reply-To: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> Luck, Tony wrote on Tuesday, April 13, 2004 9:26 AM

> >Rahul Chaturvedi wrote on Monday, April 12, 2004 10:17 PM
> >d.) The pfs register seems to point to a location in
> >0xcxxxxxxxxxxxxxxx. Shouldn't this point to some
> >accessible memory location (from usermode)?
>
> someone else can take this one?

ar.pfs is not a memory address pointer. See section 3.1.8.10 of
ia64 software developer's manual, volume 1 for proper way to
decode that register (FYI, bit [63-62] is previous privilege
level, which is 3 in the above case).

- Ken



From: Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net>
Date: Mon, 23 Aug 2004 08:29:20 +0000
Subject: Re: [PATCH&RFC 2/2] OS_MCA Recovery from poisoned memory read
Message-Id: <4129AAE0.4726DAC8@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <41121484.40804@jp.fujitsu.com>
In-Reply-To: <41121484.40804@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hidetoshi Seto wrote:
> 
> Keith Owens wrote:
> > mca_handler_bh() is running as an extension of the MCA event which
> > means that it is not irq safe.  It is not safe to get any external lock
> > in mca_page_isolate() or mca_handler_bh().
> 
> Therefore the MCA handler couldn't recover the system if the process is
> running in kernel-mode since it possibly has such important kernel locks.
> 
> > AFAICT, my concerns about the MCA event and mca_handler_bh() not being
> > irq safe are only a problem for the case when the MCA was triggered by
> > user space code but was delivered when the cpu was in kernel code.
> > Maybe we do not support the problem case.
> >
> > *    offending process  affected process  OS MCA do
> > *     kernel mode        kernel mode       down system
> > *     kernel mode        user   mode       kill the process
> > *     user   mode        kernel mode       kill the process <== problem
> > *     user   mode        user   mode       kill the process
> 
> So we have to guarantee that the process is running in user-mode,
> which all processes can't have any locks of kernel, right?
> 
> It would be happy if this fixed patch satisfy your requirement.
> 

Surprising it looks like a discovery (locking problem within the
mca handler) ?

Here is Zoltan's document including a design that exposes a solution 
how to avoid race (paragraphs 3.5, 3.5.1, 3.5.2 ...) and many other
stuff :
  http://mca-recovery.sourceforge.net
    Linux Itanium MCA Recovery Design Document, third draft
      http://mca-recovery.sourceforge.net/mca3.html

-- 
+======+============+=================+
|  |\/\/\/| |                       |                                  |
|  |      | |Christian Cotte-Barrot |org.  :BULL/                      |
|  | (~)(o) |Bull S.A.              |office:FREC/B1-401                |
| C      _) |1, rue de Provence     |mailto:                           |
|  | ,___|  |B.P. 208               |   Christian.Cotte-Barrot@bull.net|
|  |   /    |38432 ECHIROLLES CEDEX |phone :+33 (0)476297725 (229 7725)|
| /----\    |FRANCE                 |fax   :+33 (0)476297518 (229 7518)|
+======+============+=================+

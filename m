From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 22 Apr 2004 02:37:58 +0000
Subject: RE: [PATCH][RFC] Vector sharing
Message-Id: <MDEEKOKJPMPMKGHIFAMAOEELDNAA.kaneshige.kenji@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jean-Francois,

> I agree with you ACPI IRQ cleanup patch or my patch only stops the
> waste of the vector resource for line not used but doesn't solve  the
> problem completely.

Thank you :)

> In addition with on of theses patch our patch set_rte() should get
> iosapic_lock is mandatory.

I think both of your patch needs to get iosapic_lock in
iosapic_register_intr()
also. Please see following message:

http://www.gelato.unsw.edu.au/linux-ia64/0404/9352.html

Thanks,
Kenji Kaneshige

-----Original Message-----
From: Jean-Francois Neyroud [mailto:Jean-Francois.Neyroud@bull.net]
Sent: Wednesday, April 21, 2004 3:26 PM
To: Kenji Kaneshige
Cc: linux-ia64@vger.kernel.org; Bjorn Helgaas
Subject: Re: [PATCH][RFC] Vector sharing




Kenji Kaneshige wrote:

Hi,

Thank you for your comments.


An other or complementary way is to attach a vector only for interrupt
lines witch are used, PCI slots have 4 interrupt lines but only 1 or
sometime 2 are used by adapters.


I agree with attaching a vector only for interrupt lines which are used.
Your patch stops the waste of the vector resource, and it becomes difficult
for the lack of vectors to happen. I think we can also do this by using
Bjorn's
ACPI IRQ cleanup patch. To tell the truth, I also had a same idea before.

However, this idea doesn't solve the problem completely. The problem will
happen in the following case:

	o many PCI adapters have 2 or more functions
	o machine has more than 184 PCI slots in the same domain

So, I think vector sharing is necessary to solve this problem.


I agree with you ACPI IRQ cleanup patch or my patch only stops the waste of
the vector resource for line not used but doesn't solve  the problem
completely.
In addition with on of theses patch our patch set_rte() should get
iosapic_lock is mandatory.

Jean-Francois


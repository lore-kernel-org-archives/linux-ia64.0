From: Neil Gorsuch <ngorsuch@ncsa.uiuc.edu>
Date: Tue, 17 Sep 2002 21:30:14 +0000
Subject: [Linux-ia64] Re: redhat or mandrake on HP i2000 ia64 ?
Message-Id: <marc-linux-ia64-105590701906032@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906031@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906031@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It turns out that when I did a low level reformat of the scsi disk, as per 
Michael Mackey's suggestion on the ia64-list@redhat.com, the problem goes 
away. Another problem that I discovered is that the redhat install becomes 
very confused when the KVM is in a strange mouse state. Thanks all for your 
suggestions.

At 01:39 PM 9/16/2002 -0400, Bill Nottingham wrote:
>Neil Gorsuch (ngorsuch@ncsa.uiuc.edu) said:
> > The redhat 7.2 CD boots, gets to the point saying "loading qla1280 scsi
> > driver" , waits a while,
> > then outputs:
> >
> > exec: permission denied
>
>Are there IDE errors, perchance, on VT3 or VT4?
>
>Bill



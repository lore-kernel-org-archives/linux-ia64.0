From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 16 Aug 2005 21:48:43 +0000
Subject: Re: [PATCH] IDE: don't offer IDE_GENERIC on ia64
Message-Id: <1124228924.22924.8.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508111424.43150.bjorn.helgaas@hp.com>
	 <200508151507.22776.bjorn.helgaas@hp.com>
	 <58cb370e050816023845b57a74@mail.gmail.com>
	 <200508161316.32602.bjorn.helgaas@hp.com>
	 <1124223946.22924.4.camel@localhost.localdomain>
	 <58cb370e050816134270b445ea@mail.gmail.com>
In-Reply-To: <58cb370e050816134270b445ea@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, B.Zolnierkiewicz@elka.pw.edu.pl, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-ia64@vger.kernel.org

On Maw, 2005-08-16 at 22:42 +0200, Bartlomiej Zolnierkiewicz wrote:
> IMO this is much better solution as:
> * you go from working code into small steps (evolution)

If there was working code to go from maybe. The IDE core code is far too
broken for that to be the case. The drivers are different matter
although the driver API is fundamentally flawed because it handles speed
changing in a synchronous manner.

> * it shouldn't be that hard - I have many parts of the stuff
>   done (they need some polishing)

Fair enough. Be good to see the core IDE get better whichever path


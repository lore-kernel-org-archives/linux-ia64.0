From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 27 Nov 2006 08:52:24 +0000
Subject: Re: Ski for huge page size !
Message-Id: <87d579jmpj.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <9b33a9230611252206l777e3bcfr5795b0b16668183f@mail.gmail.com>
In-Reply-To: <9b33a9230611252206l777e3bcfr5795b0b16668183f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: sudhnesh adapawar <sudhnesh@gmail.com>
Cc: linux-ia64@vger.kernel.org, lia64-sim@napali.hpl.hp.com, linux-kernel@vger.kernel.org, kernelnewbies@nl.linux.org

>>>>> "sudhnesh" = sudhnesh adapawar <sudhnesh@gmail.com> writes:

sudhnesh> Hey all !  I am thinking to use ski simulator as I can get
sudhnesh> the ia64 (Itanium 2)simulated on ia32 archi....So can I use
sudhnesh> this product for the project related to huge page size ???
sudhnesh> Will the problems related to huge pages such as
sudhnesh> swapping,IO,etc...will be covered if I use ski with 2.6
sudhnesh> kernel image configured for ia64 archi with huge page size
sudhnesh> support ?????


Should work perfectly.  We've been using Ski for similar work, looking
at SuperPage support.
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia

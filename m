From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 08 Nov 2006 09:19:08 +0000
Subject: Re: IA64 simulator !
Message-Id: <20061108091908.GA25476@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9b33a9230611072145x6a2be5f0y5dfacd968d44d175@mail.gmail.com>
In-Reply-To: <9b33a9230611072145x6a2be5f0y5dfacd968d44d175@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

On Wed, Nov 08, 2006 at 11:15:43AM +0530, sudhnesh adapawar wrote:
> Hey all !
>            I have ski simulator for ia64 ! I installed this on
> i386/i686 architecture ! In order to simulate ia64 archi on ia32 archi
> we need to create cross compilation environment and complete cross
> compilation !

Are you trying to cross-compile just the Linux kernel or also user level
applications?

>            Now,is there any options to avoid this cross compilation
> process and dirrectly install linux os for the ia64 simulator? Is
> there any ISO image?

No, this is not supported.

In case you are trying to test user level applications on IA-64, I would
like to point out that HP offers a way to test your applications on a bunch
of different HW and OSes. This service is available (for free) at the following
site:
	http://www.testdrive.hp.com/
 
-- 
-Stephane

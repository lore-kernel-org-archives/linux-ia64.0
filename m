From: Benjamin LaHaise <bcrl@kvack.org>
Date: Fri, 19 Sep 2003 10:49:22 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106396861522161@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 19, 2003 at 07:53:04AM +0200, Andi Kleen wrote:
> You must add the 2 bytes in dev_alloc_skb() too.
> 
> (it also add 16 bytes by itself, but they are used for other things)

Sorry, the chipset does not support packet rx into unaligned buffers.  
stoopid.  Fwiw, the copy code got removed by davem -- isn't the core 
dealubg wuth unakugned packets now?

		-ben
-- 
"The software industry today survives only through an unstated agreement 
not to stir things up too much.  We must hope this lawsuit [by SCO] isn't 
the big stirring spoon." -- Ian Lance Taylor, Linux Journal, June 2003
